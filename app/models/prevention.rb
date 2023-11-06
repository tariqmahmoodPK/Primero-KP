# frozen_string_literal: true

class Prevention < ApplicationRecord
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
  # Simplifies location service integration in records by providing an attribute writer to set the location service
  # and a method to access the LocationService singleton. Essential for efficient location-based operations in records.
  include LocationCacheable

  # Helper Methods for the Graphs
  extend PreventionGraphHelpers
  # Methods to Calculate Stats for Graphs
  extend PreventionGraphs

  # Accessors
  store_accessor(
    :data,
    :prevention_id,
    :registration_date,
    :prevention_id_display,
    :name,
    :hidden_name,
    :module_id,
    :location_current,
    # Prevention Forms
    :influencer_mapping,
    :details_of_meetings,
    :community_engagement_sessions,
    :male_community_based_child_protection_committees,
    :female_community_based_child_protection_committees,
    :capacity_building_training_or_workshop_received,
    :awareness_session_conducted_in_the_community,
    :community_mobilization,
    :community_based_child_protection_committee_training,
    :capacity_building_training_or_workshop_delivered,
    :event_celebrations,
  )

  # This string represents the endpoint or path that clients can use to interact with Prevention records in the API
  def self.api_path
    '/api/v2/preventions'
  end

  class << self
    def filterable_id_fields
      %w[ prevention_id short_id ]
    end

    def quicksearch_fields
      filterable_id_fields + %w[ name ]
    end

    def summary_field_names
      common_summary_fields + %w[
        prevention_id_display
        name
        registration_date
        module_id
        location_current
      ]
    end

    def sortable_text_fields
      %w[ short_id name ]
    end
  end

  searchable do
    %w[ id status ].each { |f| string(f, as: "#{f}_sci") }
    %w[ registration_date ].each { |f| date(f) }
    filterable_id_fields.each { |f| string("#{f}_filterable", as: "#{f}_filterable_sci") { data[f] } }
    quicksearch_fields.each { |f| text_index(f) }
    sortable_text_fields.each { |f| string("#{f}_sortable", as: "#{f}_sortable_sci") { data[f] } }
  end

  alias super_defaults defaults
  def defaults
    super_defaults
    self.registration_date ||= Date.today
  end

  def self.report_filters
    [
      { 'attribute' => 'status', 'value' => [STATUS_OPEN] },
      { 'attribute' => 'record_state', 'value' => ['true'] }
    ]
  end

  def set_instance_id
    self.prevention_id ||= unique_identifier
    self.prevention_id_display ||= short_id
  end
end

# rubocop:enable Metrics/ClassLength
