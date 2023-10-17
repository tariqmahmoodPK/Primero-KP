# frozen_string_literal: true

# The "Webhookable" module provides supporting logic and fields for integrating webhooks in records. It enables records
# to interact with external systems using webhooks and manage webhook-related attributes.
# It also handles webhook status and log records to track synchronization with external systems.
# It provides functionality to manage webhook synchronization attributes and log webhook status.
# This module makes it easier to integrate records with external systems for real-time data exchange.

module Webhookable
  extend ActiveSupport::Concern

  included do
    store_accessor :data, :mark_synced, :mark_synced_url, :mark_synced_status

    before_update :log_sync_status, if: :valid_sync_log
    before_update :clean_sync_attributes, if: :valid_sync_log
    after_create { queue_for_webhook(Webhook::CREATE) }
    after_update { queue_for_webhook(Webhook::UPDATE) }
  end

  # Retrieves webhook status information by executing a custom SQL query and processing the results. It returns a
  # hash with destination URLs, status, and timestamps of the latest webhook actions.

  # We'll give ourselves a rubocop pass on account of custom SQL
  # rubocop:disable Metrics/MethodLength
  def webhook_status
    return @webhook_status if @webhook_status

    sql = AuditLog.sanitize_sql(
      [
        "select logs.resource_url as destination, logs.metadata ->> 'webhook_status' as status, logs.timestamp " \
        'from audit_logs logs,' \
        '     (select resource_url, max(timestamp) as max_timestamp' \
        '      from audit_logs' \
        "      where record_id = :record_id and record_type = :record_type and action = 'webhook'" \
        '      group by resource_url) latest ' \
        'where logs.resource_url = latest.resource_url' \
        '      and logs.timestamp = latest.max_timestamp' \
        '      and logs.record_id = :record_id' \
        '      and logs.record_type = :record_type' \
        "      and logs.action = 'webhook'",
        { record_id: id, record_type: self.class.name }
      ]
    )
    @webhook_status = AuditLog.connection.select_all(sql).to_a
                              .map { |r| [r['destination'], DestringifyService.destringify(r)] }
                              .to_h.with_indifferent_access
  end
  # rubocop:enable Metrics/MethodLength

  # Orders webhook status information by timestamp in descending order, ensuring the most recent statuses come first.
  def ordered_webhook_status
    @ordered_webhook_status ||= webhook_status.values.sort { |a, b| b[:timestamp] <=> a[:timestamp] }
  end

  # Retrieves the timestamp of the latest successful synchronization from ordered webhook status data.
  # TODO: Right now the synced_at values look at all webhooks. This will be very inaccurate if we start registering
  #       multiple webhooks. Once we start expecting syncs from more than just open function, we will need to
  #       alter these methods and redesign the UI.
  def synced_at
    ordered_webhook_status.find { |s| s[:status] == AuditLog::SYNCED }&.[](:timestamp)
  end

  # Retrieves the status of the latest synchronization from ordered webhook status data.
  def sync_status
    ordered_webhook_status&.first&.[](:status)
  end

  # Checks if webhooks are configured for the record type based on the "use_webhooks_for" setting.
  def webhook_configured?
    self.module&.use_webhooks_for&.include?(self.class.parent_form)
  end

  # Queues a webhook job for a specified action, such as creating or updating the record. The job will trigger
  # webhook integration for this record.
  def queue_for_webhook(action)
    WebhookJob.perform_later(self.class.parent_form, id, action)
  end

  private

  # Determines the synchronization status based on "mark_synced" and "mark_synced_status" attributes.
  def calculate_sync_status
    synced_status = if mark_synced
                      AuditLog::SYNCED
                    else
                      AuditLog::FAILED
                    end
    mark_synced_status || synced_status
  end

  # Removes synchronization-related attributes from the "data" hash after they are no longer needed.
  def clean_sync_attributes
    %w[mark_synced mark_synced_url mark_synced_status].each do |attribute|
      attributes['data'].delete(attribute)
    end
  end

  # Creates a log entry to record the synchronization status and timestamp for webhooks.
  def log_sync_status
    AuditLog.create(
      record: self, resource_url: mark_synced_url, action: AuditLog::WEBHOOK,
      webhook_status: calculate_sync_status, timestamp: DateTime.now
    )
  end

  # Checks if there is valid synchronization data in the record before creating log entries.
  def valid_sync_log
    mark_synced_status.present? || mark_synced.present?
  end
end
