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

  # Closed Cases by Sex and Protection Concern
  # New name 'Closed Cases by Sex and Reason'
  #TODO Rename All of it's relevant methods, and files to reflect the proper name.
  def resolved_cases_by_gender_and_types_of_violence_stats
    #TODO Create a method for this later on.
    #TODO had to do this as there is no lookup create for Closure form's what_is_the_reason_for_closing_this_case__d2d2ce8 field
    #TODO the lookups are hardcoded into the field itself.
    form_to_work_with = FormSection.where("name_i18n->>'en' = ? AND form_group_id = ?", "Closure", "closure").first
    form_field = form_to_work_with.fields.find_by(name: "what_is_the_reason_for_closing_this_case__d2d2ce8")
    @lookup_values = form_field.option_strings_text_i18n

    @stats = Child.resolved_cases_by_gender_and_types_of_violence(current_user)
  end

  # Cases Referral (To Agency )
  def cases_referral_to_agency_stats
    @stats = Child.cases_referral_to_agency(current_user)
  end
end
