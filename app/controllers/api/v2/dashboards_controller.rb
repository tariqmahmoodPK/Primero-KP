# frozen_string_literal: true

# API for fetching the aggregate statistics backing the dashboards
class Api::V2::DashboardsController < ApplicationApiController
  def index
    current_user.user_groups.load
    @dashboards = current_user.role.dashboards
    indicators = @dashboards.map(&:indicators).flatten
    @indicator_stats = IndicatorQueryService.query(indicators, current_user)
  end

  # 'Percentage of Children who received Child Protection Services' Graph
  def percentage_children_received_child_protection_services
    @stats = Child.percentage_children_received_child_protection_services_stats(current_user)
  end

  # 'Closed Cases by Sex and Reason' Graph
  def resolved_cases_by_gender_and_reason
    @stats = Child.resolved_cases_by_gender_and_reason_stats(current_user)

    # Properly format the stats to use on the React Component
    lookup_values = Lookup.reason_for_closing_case_values

    closed_cases_by_sex_and_reason = {}

    @stats.each do |key, value|
      # Find the corresponding entry in the lookup_values array
      lookup_entry = lookup_values.find { |entry| entry["id"] == key.to_s }

      if lookup_entry
        # Get the English label from the lookup entry
        english_label = lookup_entry["display_text"]["en"]
        # Add the English label as a new key in the closed_cases_by_sex_and_reason hash
        closed_cases_by_sex_and_reason[english_label] = value
      end
    end

    # The new stats format is like this:
    # {
    #   "Case goals all met" => {:male=>0, :female=>0, :transgender=>0},
    #   "Case goals substantially met and there is no further child protection concern" => {:male=>0, :female=>0, :transgender=>0},
    #   "Child reached adulthood" => {:male=>0, :female=>0, :transgender=>0},
    #   "Child refuses services" => {:male=>0, :female=>0, :transgender=>0},
    #   "Safety of child" => {:male=>0, :female=>0, :transgender=>0},
    #   "Death of child" => {:male=>0, :female=>0, :transgender=>0},
    #   "Other" => {:male=>0, :female=>0, :transgender=>0}
    # }

    @stats = closed_cases_by_sex_and_reason
  end

  # TODO Need to Modify logic
  # TODO The form field for are not present in the current dump
  # Cases Referral (To Agency )
  def cases_referral_to_agency_stats
    @stats = Child.cases_referral_to_agency(current_user)
  end

  # Cases requiring Alternative Care Placement Services
  #TODO Rename All of it's relevant methods, and files to reflect the proper name.
  def alternative_care_placement_by_gender
    @stats = Child.alternative_care_placement_by_gender(current_user)
  end

  # Registered and Closed Cases by Month
  #TODO Rename All of it's relevant methods, and files to reflect the proper name.
  def month_wise_registered_and_resolved_cases_stats
    @stats = Child.month_wise_registered_and_resolved_cases(current_user)
  end

  #TODO Rename All of it's relevant methods, and files to reflect the proper name.
  # Significant Harm Cases by Protection Concern
  def significant_harm_cases_registered_by_age_and_gender_stats
    @stats = Child.significant_harm_cases_registered_by_age_and_gender(current_user)
  end

  #TODO Rename All of it's relevant methods, and files to reflect the proper name.
  # Registered Cases by Protection Concern
  def registered_cases_by_protection_concern
    @stats = Child.registered_cases_by_protection_concern_stats(current_user)
  end
end
