# frozen_string_literal: true

# Describes a request by a single individual to trace one or more children (cases)
class TracingRequest < ApplicationRecord
  # Defines shared functionality and characteristics for all core Primero record types, enhancing code consistency and maintainability.
  include Record
  # Provides functionality for indexing and searching record fields using the Sunspot search library, including handling different field types and custom indexing configurations.
  include Searchable
  # This describes all models that may be owned by a particular user
  include Ownable
  # Adds the ability to track and manage the historical information of records, including creation and updates.
  # Essential for maintaining historical data within record management systems.
  include Historical
  # Provides the ability to flag records, allowing for the marking and categorization of records for different
  # purposes. Useful for systems that require flagging records for special attention or categorization.
  include Flaggable
  # Adds alert management features to records, allowing them to handle different alert types.
  # Useful for tracking and responding to events like field changes, new forms, and approval requests
  # within record management systems.
  include Alertable
  # Enables the declaration and management of record attachments, including images, audio, and documents.
  # Particularly useful for systems dealing with attachment-heavy records.
  include Attachable
  # Enhances database query efficiency by enabling eager loading of specified associations for records.
  include EagerLoadable
  # Enables records to interact with external systems using webhooks, offering support for managing webhook-related
  # attributes and tracking synchronization status. An essential tool for real-time data exchange.
  include Webhookable
  # Simplifies location service integration in records by providing an attribute writer to set the location service
  # and a method to access the LocationService singleton. Essential for efficient location-based operations in records.
  include LocationCacheable

  has_many :traces

  store_accessor :data,
                 :tracing_request_id, :inquiry_date, :relation_name, :relation_age,
                 :relation_date_of_birth, :relation_sex,
                 :relation_nickname, :relation_other_family, :relation,
                 :relation_nationality, :relation_language, :relation_religion,
                 :relation_ethnicity, :relation_sub_ethnicity1, :relation_sub_ethnicity2,
                 :monitor_number, :survivor_code, :reunited, :inquiry_date,
                 :location_last
  alias inquirer_id tracing_request_id

  after_save :save_traces

  class << self
    def filterable_id_fields
      %w[tracing_request_id short_id]
    end

    def quicksearch_fields
      filterable_id_fields + %w[relation_name relation_nickname tracing_names tracing_nicknames]
    end

    def summary_field_names
      common_summary_fields + %w[
        relation_name inquiry_date tracing_names
      ]
    end

    def minimum_reportable_fields
      {
        'boolean' => ['record_state'],
        'string' => %w[status owned_by],
        'multistring' => %w[associated_user_names owned_by_groups],
        'date' => ['inquiry_date']
      }
    end

    alias super_new_with_user new_with_user
    def new_with_user(user, data)
      traces_data = data.delete('tracing_request_subform_section')
      new_tracing_request = super_new_with_user(user, data)
      new_tracing_request.build_or_update_traces(traces_data)
      new_tracing_request
    end

    alias super_eager_loaded_class eager_loaded_class
    def eager_loaded_class
      super_eager_loaded_class.includes(:traces)
    end
  end

  def self.sortable_text_fields
    %w[relation_name tracing_names short_id]
  end

  searchable do
    %w[id status].each { |f| string(f, as: "#{f}_sci") }
    filterable_id_fields.each { |f| string("#{f}_filterable", as: "#{f}_filterable_sci") { data[f] } }
    quicksearch_fields.each { |f| text_index(f) }
    sortable_text_fields.each do |f|
      string("#{f}_sortable", as: "#{f}_sortable_sci") do
        value = data[f] || send(f)
        value.is_a?(Array) ? value.join(' ') : value
      end
    end
  end

  alias super_defaults defaults
  def defaults
    super_defaults
    self.inquiry_date ||= Date.today
  end

  alias super_update_properties update_properties
  def update_properties(user, data)
    build_or_update_traces(data.delete('tracing_request_subform_section'))
    super_update_properties(user, data)
  end

  def build_or_update_traces(traces_data)
    return unless traces_data

    @traces_to_save = traces_data.map do |trace_data|
      trace = Trace.find_or_initialize_by(id: trace_data['unique_id']) do |new_trace|
        new_trace.data = trace_data
        new_trace.tracing_request = self
      end
      trace.data = RecordMergeDataHashService.merge_data(trace.data, trace_data) unless trace.new_record?
      trace
    end
  end

  def save_traces
    return unless @traces_to_save

    Trace.transaction do
      @traces_to_save.each(&:save!)
    end
  end

  def associations_as_data(_current_user)
    traces.reload if @traces_to_save.present?
    @associations_as_data ||= { 'tracing_request_subform_section' => traces.map(&:data) }
  end

  def associations_as_data_keys
    %w[tracing_request_subform_section]
  end

  def tracing_names
    traces.map(&:name).compact
  end

  def tracing_nicknames
    traces.map(&:name_nickname).compact
  end

  def set_instance_id
    self.tracing_request_id ||= unique_identifier
  end
end
