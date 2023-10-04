# frozen_string_literal: true

# API for fetching the aggregate statistics backing the dashboards
class Api::V2::DashboardsController < ApplicationApiController
  def index
    current_user.user_groups.load
    @dashboards = current_user.role.dashboards
    indicators = @dashboards.map(&:indicators).flatten
    @indicator_stats = IndicatorQueryService.query(indicators, current_user)
  end

  # Graph for 'Percentage of Children who received Child Protection Services'
  #TODO Rename All of it's relevant methods, and files to reflect the proper name.
    #TODO May be percentage_of_children_who_received_child_protection_services
    #TODO or children_percentage_who_received_child_protection_services
    #TODO or protection_concerns_services_received_stats
  def protection_concerns_services_stats
    @stats = Child.protection_concern_stats(current_user)
  end
end
