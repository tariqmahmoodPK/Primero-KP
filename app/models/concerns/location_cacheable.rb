# frozen_string_literal: true

# The "LocationCacheable" module provides a shared concern to initialize the LocationService. It defines an
# attribute writer for setting the location service and offers a convenient method for accessing the LocationService
# singleton. This module simplifies the management of location-related services in records.
module LocationCacheable
  extend ActiveSupport::Concern

  attr_writer :location_service

  # Retrieves the LocationService instance, initializing it if not already set, and returns the cached instance.
  def location_service
    @location_service ||= LocationService.instance
  end
end
