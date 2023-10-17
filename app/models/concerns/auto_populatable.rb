# frozen_string_literal: true

# This module allows records to derive field values based on configured SystemSettings.
# The "AutoPopulatable" module is designed to enable records to derive field values automatically based on
# the configuration in SystemSettings.
# It provides methods to fetch auto-populate information, generate values using a specified format, and retrieve
# auto-populate separators.
# This module is useful for scenarios where certain record fields need to be automatically populated according to predefined rules or patterns.

# Derive field values on records, as configured in SystemSettings.
# TODO: Really this should live in a service.
module AutoPopulatable
  extend ActiveSupport::Concern

  # Fetches the auto-populate information and generates a value based on the configured format.
  def fetch_auto_populate_info(auto_populate_info)
    id_code_parts = []

    # Evaluate each format part using PropertyEvaluator and store the results.
    auto_populate_info.format.each { |pf| id_code_parts << PropertyEvaluator.evaluate(self, pf) }

    # Join the non-blank parts using the specified separator.
    id_code_parts.reject(&:blank?).join(auto_populate_info.separator)
  end

  # Automatically populates a field based on the given field key and SystemSettings.
  def auto_populate(field_key, system_settings = nil)
    @system_settings ||= (system_settings || SystemSettings.current)

    # Retrieve auto-populate information from SystemSettings based on the provided field key.
    auto_populate_info = @system_settings.auto_populate_info(field_key) if @system_settings.present?

    # Return unless auto-population is enabled, and a format is specified.
    return unless auto_populate_info&.auto_populated == true && auto_populate_info.format.present?

    # Generate and return the auto-populated value.
    fetch_auto_populate_info(auto_populate_info)
  end

  # Retrieves the auto-populate separator for a given field based on field key and SystemSettings.
  def auto_populate_separator(field_key, system_settings = nil)
    @system_settings ||= (system_settings.present? ? system_settings : SystemSettings.current)

    # Retrieve auto-populate information from SystemSettings based on the provided field key.
    auto_populate_info = @system_settings.auto_populate_info(field_key) if @system_settings.present?

    # Return the separator if auto-populate information is present, otherwise an empty string.
    auto_populate_info.present? ? auto_populate_info.separator : ''
  end
end
