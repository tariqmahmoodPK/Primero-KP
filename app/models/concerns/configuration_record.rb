# frozen_string_literal: true

# A shared concern for all Primero configuration types: FormSections, Agencies, Lookups, etc.

# The ConfigurationRecord concern serves as a reusable component, Designed to streamline the management of various configuration records
  # such as FormSections, Agencies, and Lookups. It achieves this by offering a set of common functionalities.
# By encapsulating these functionalities in a shared concern, ConfigurationRecord provides a standardized and
  # consistent way to handle configuration data across different parts of the application.
  # This abstraction simplifies the code and fosters maintainability by reducing redundancy and ensuring
  # that records adhere to a common structure and behavior.
#

module ConfigurationRecord
  extend ActiveSupport::Concern

  # Default Unique ID Handling:
    # It allows you to specify the attribute used as the unique ID and the attribute from which the unique ID should be generated for configuration records.
  #
  included do
    # Set the default unique id attributes
    self.unique_id_attribute = 'unique_id'
    self.unique_id_from_attribute = 'name'
  end

  # Class methods
  module ClassMethods
    # This simplifies the process of creating or updating configuration records based on a provided configuration hash.
    # This method ensures that records are updated if a matching unique ID is found or created if it doesn't exist.
    def create_or_update!(configuration_hash)
      configuration_hash = configuration_hash.with_indifferent_access if configuration_hash.is_a?(Hash)
      configuration_record = find_or_initialize_by(unique_id_attribute => configuration_hash[unique_id_attribute])
      configuration_record.update_properties(configuration_hash)
      configuration_record.save!
      configuration_record
    end

    def unique_id_attribute
      @unique_id_attribute
    end

    def unique_id_attribute=(attribute)
      @unique_id_attribute = attribute.to_s
    end

    def unique_id_from_attribute
      @unique_id_from_attribute
    end

    def unique_id_from_attribute=(attribute = 'name')
      @unique_id_from_attribute = attribute.to_s
    end

    # NOTE Override this in the implementing class if data needs to be applied in a special order
    def sort_configuration_hash(configuration_hash)
      configuration_hash
    end
  end

  # For a given configuration record, the instance method configuration_hash generates a hash that represents the record's attributes.
  # This hash excludes standard ActiveRecord attributes, making it more manageable and accessible.
  def configuration_hash
    attributes.except('id', 'created_at', 'updated_at').with_indifferent_access
  end

  # This method allows easy attribute updates for a configuration record.
  # It streamlines the assignment of attribute values based on a provided configuration hash.
  def update_properties(configuration_hash)
    self.attributes = configuration_hash
  end

  # Unique ID Generation:
    # This provide a mechanism for generating unique IDs, mainly based on the value of the specified attribute,
    # such as name. If the source attribute exists, it creates a unique and easily identifiable ID for the record.
  #
  def generate_unique_id
    generate_from = send(self.class.unique_id_from_attribute)
    return unless generate_from.present?

    self[self.class.unique_id_attribute] ||= unique_id_from_string(generate_from)
  end

  def unique_id_from_string(string)
    code = SecureRandom.uuid.to_s.last(7)
    string = string.gsub(/[^A-Za-z0-9_ ]/, '')
    "#{self.class.name}-#{string}-#{code}".parameterize.dasherize
  end
end
