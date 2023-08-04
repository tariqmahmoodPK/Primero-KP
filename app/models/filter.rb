# frozen_string_literal: true

# The value bag representing the list view filters, and the hardcoded set of these filters in Primero
# rubocop:disable Metrics/ClassLength
class Filter < ValueObject
  attr_accessor :name, :field_name, :type, :options, :option_strings_source

  FLAGGED_CASE = Filter.new(
    name: 'cases.filter_by.flag',
    field_name: 'flagged',
    options: I18n.available_locales.map do |locale|
      { locale => [{ id: 'true', display_name: I18n.t('cases.filter_by.flag_label', locale: locale) }] }
    end.inject(&:merge)
  )
  MOBILE_CASE = Filter.new(
    name: 'cases.filter_by.mobile',
    field_name: 'marked_for_mobile',
    options: I18n.available_locales.map do |locale|
      { locale => [{ id: 'true', display_name: I18n.t('cases.filter_by.mobile_label', locale: locale) }] }
    end.inject(&:merge)
  )
  SOCIAL_WORKER = Filter.new(name: 'cases.filter_by.social_worker', field_name: 'owned_by')
  RECORD_OWNER = Filter.new(name: 'incidents.filter_by.record_owner', field_name: 'owned_by')
  MY_CASES = Filter.new(name: 'cases.filter_by.my_cases', field_name: 'my_cases')
  WORKFLOW = Filter.new(name: 'cases.filter_by.workflow', field_name: 'workflow')
  DATE_CASE = Filter.new(
    name: 'cases.filter_by.by_date',
    field_name: 'cases_by_date',
    type: 'dates'
  )
  APPROVALS_STATUS_ASSESSMENT = Filter.new(name: 'approvals.assessment', field_name: 'approval_status_assessment')
  APPROVALS_STATUS_CASE_PLAN = Filter.new(name: 'approvals.case_plan', field_name: 'approval_status_case_plan')
  APPROVALS_STATUS_CLOSURE = Filter.new(name: 'approvals.closure', field_name: 'approval_status_closure')
  APPROVALS_STATUS_ACTION_PLAN = Filter.new(name: 'approvals.action_plan', field_name: 'approval_status_action_plan')
  APPROVALS_STATUS_GBV_CLOSURE = Filter.new(name: 'approvals.gbv_closure', field_name: 'approval_status_gbv_closure')
  AGENCY =  Filter.new(name: 'cases.filter_by.agency', field_name: 'owned_by_agency_id', type: 'checkbox')
  STATUS =  Filter.new(
    name: 'cases.filter_by.status',
    field_name: 'status',
    option_strings_source: 'lookup-case-status'
  )
  AGE_RANGE = Filter.new(
    name: 'cases.filter_by.age_range',
    field_name: 'age',
    type: 'multi_toggle'
  )
  SEX = Filter.new(
    name: 'cases.filter_by.sex',
    field_name: 'sex',
    option_strings_source: 'lookup-gender'
  )
  PROTECTION_CONCERNS = Filter.new(
    name: 'cases.filter_by.protection_concerns',
    field_name: 'protection_concerns',
    option_strings_source: 'lookup-protection-concerns'
  )
  GBV_DISPLACEMENT_STATUS = Filter.new(
    name: 'cases.filter_by.displacement_status',
    field_name: 'gbv_displacement_status',
    option_strings_source: 'lookup-displacement-status'
  )
  PROTECTION_STATUS = Filter.new(
    name: 'cases.filter_by.protection_status',
    field_name: 'protection_status',
    option_strings_source: 'lookup-protection-status'
  )
  URGENT_PROTECTION_CONCERN = Filter.new(
    name: 'cases.filter_by.urgent_protection_concern',
    field_name: 'urgent_protection_concern',
    option_strings_source: 'lookup-yes-no'
  )
  TYPE_OF_RISK = Filter.new(
    name: 'cases.filter_by.type_of_risk',
    field_name: 'type_of_risk',
    option_strings_source: 'lookup-risk-type'
  )
  RISK_LEVEL = Filter.new(
    name: 'cases.filter_by.risk_level',
    field_name: 'risk_level',
    option_strings_source: 'lookup-risk-level',
    type: 'chips'
  )
  CURRENT_LOCATION = Filter.new(
    name: 'cases.filter_by.current_location',
    field_name: 'location_current',
    option_strings_source: 'Location',
    type: 'multi_select'
  )
  AGENCY_OFFICE = Filter.new(
    name: 'user.agency_office',
    field_name: 'owned_by_agency_office',
    option_strings_source: 'lookup-agency-office'
  )
  USER_GROUP = Filter.new(name: 'permissions.permission.user_group', field_name: 'owned_by_groups')
  REPORTING_LOCATION = lambda do |params|
    Filter.new(
      name: "location.base_types.#{params[:labels]&.first}",
      field_name: "#{params[:field]}#{params[:admin_level]}",
      option_strings_source: 'ReportingLocation',
      type: 'multi_select'
    )
  end
  NO_ACTIVITY = Filter.new(
    name: 'cases.filter_by.no_activity',
    field_name: 'last_updated_at'
  )
  ENABLED = Filter.new(
    name: 'cases.filter_by.enabled_disabled',
    field_name: 'record_state',
    options: I18n.available_locales.map do |locale|
      {
        locale => [
          { id: 'true', display_name: I18n.t('disabled.status.enabled', locale: locale) },
          { id: 'false', display_name: I18n.t('disabled.status.disabled', locale: locale) }
        ]
      }
    end.inject(&:merge)
  )
  PHOTO = Filter.new(
    name: 'cases.filter_by.photo',
    field_name: 'has_photo',
    options: I18n.available_locales.map do |locale|
      {
        locale => [
          { id: 'photo', display_name: I18n.t('cases.filter_by.photo_label', locale: locale) }
        ]
      }
    end.inject(&:merge)
  )
  VIOLENCE_TYPE = Filter.new(
    name: 'incidents.filter_by.violence_type',
    field_name: 'gbv_sexual_violence_type',
    option_strings_source: 'lookup-gbv-sexual-violence-type'
  )
  CHILDREN = Filter.new(
    name: 'incidents.filter_by.children',
    field_name: 'child_types',
    options: I18n.available_locales.map do |locale|
      {
        locale => [
          { id: 'boys', display_name: I18n.t('incidents.filter_by.boys', locale: locale) },
          { id: 'girls', display_name: I18n.t('incidents.filter_by.girls', locale: locale) },
          { id: 'unknown', display_name: I18n.t('incidents.filter_by.unknown', locale: locale) }
        ]
      }
    end.inject(&:merge)
  )
  INCIDENT_STATUS = Filter.new(
    name: 'incidents.filter_by.status',
    field_name: 'status',
    option_strings_source: 'lookup-incident-status'
  )
  VERIFICATION_STATUS = Filter.new(
    name: 'incidents.filter_by.verification_status',
    field_name: 'verification_status',
    option_strings_source: 'lookup-verification-status'
  )
  INCIDENT_LOCATION = Filter.new(
    name: 'incidents.filter_by.incident_location',
    field_name: 'incident_location',
    option_strings_source: 'Location',
    type: 'multi_select'
  )
  INCIDENT_DATE = Filter.new(
    name: 'incidents.filter_by.by_date',
    field_name: 'incidents_by_date',
    type: 'dates'
  )
  UNACCOMPANIED_PROTECTION_STATUS = Filter.new(
    name: 'incidents.filter_by.unaccompanied_separated_status',
    field_name: 'unaccompanied_separated_status',
    option_strings_source: 'lookup-unaccompanied-separated-status'
  )
  ARMED_FORCE_GROUP_PARTY = Filter.new(
    name: 'incidents.filter_by.armed_force_group_party_name',
    field_name: 'armed_force_group_party_names',
    option_strings_source: 'lookup-armed-force-group-or-other-party',
    type: 'multi_select'
  )
  TRACING_REQUEST_STATUS = Filter.new(
    name: 'tracing_requests.filter_by.status',
    field_name: 'status',
    option_strings_source: 'lookup-inquiry-status'
  )
  SEPARATION_LOCATION = Filter.new(
    name: 'tracing_requests.filter_by.location_separation',
    field_name: 'location_separation',
    option_strings_source: 'Location',
    type: 'multi_select'
  )
  SEPARATION_CAUSE = Filter.new(
    name: 'tracing_requests.filter_by.separation_cause',
    field_name: 'separation_cause',
    option_strings_source: 'lookup-separation-cause'
  )
  INQUIRY_DATE = Filter.new(
    name: 'tracing_requests.filter_by.by_date',
    field_name: 'inquiry_date',
    options: I18n.available_locales.map do |locale|
      {
        locale => [
          {
            id: 'inquiry_date',
            display_name: I18n.t('tracing_requests.selectable_date_options.inquiry_date', locale: locale)
          }
        ]
      }
    end.inject(&:merge)
  )
  DATE_REGISTRY = Filter.new(
    name: 'registry_records.filter_by.by_date',
    field_name: 'registry_records_by_date',
    type: 'dates'
  )
  REGISTRY_STATUS = Filter.new(
    name: 'registry_records.filter_by.status',
    field_name: 'status',
    option_strings_source: 'lookup-registry-status'
  )
  CASE_FILTER_FIELD_NAMES = %w[
    gbv_displacement_status protection_status urgent_protection_concern
    protection_concerns type_of_risk
  ].freeze

  VIOLATION_FILTER = Filter.new(
    name: 'incidents.filter_by.violations',
    field_name: 'violation_category',
    option_strings_source: 'lookup-violation-type',
    type: 'multi_select'
  )

  INDIVIDUAL_VIOLATIONS = Filter.new(
    name: 'incidents.filter_by.individual_violations',
    field_name: 'individual_violations',
    option_strings_source: 'lookup-violation-type'
  )

  INDIVIDUAL_AGE = Filter.new(
    name: 'incidents.filter_by.individual_age',
    field_name: 'individual_age',
    type: 'multi_toggle'
  )

  INDIVIDUAL_SEX = Filter.new(
    name: 'incidents.filter_by.individual_sex',
    field_name: 'individual_sex',
    option_strings_source: 'lookup-gender-unknown'
  )

  DEPRIVED_LIBERTY_SECURITY_REASONS = Filter.new(
    name: 'incidents.filter_by.victim_deprived_liberty_security_reasons',
    field_name: 'victim_deprived_liberty_security_reasons',
    option_strings_source: 'lookup-mrm-yes-no-unknown'
  )

  REASONS_DEPRIVATION_LIBERTY = Filter.new(
    name: 'incidents.filter_by.reasons_deprivation_liberty',
    field_name: 'reasons_deprivation_liberty',
    option_strings_source: 'lookup-reasons-deprivation-liberty'
  )

  VICTIM_FACILTY_VICTIMS_HELD = Filter.new(
    name: 'incidents.filter_by.victim_facilty_victims_held',
    field_name: 'victim_facilty_victims_held',
    option_strings_source: 'lookup-detention-facility-type'
  )

  TORTURE_PUNISHMENT_WHILE_DEPRIVATED_LIBERTY = Filter.new(
    name: 'incidents.filter_by.torture_punishment_while_deprivated_liberty',
    field_name: 'torture_punishment_while_deprivated_liberty',
    option_strings_source: 'lookup-mrm-yes-no-unknown'
  )

  VERIFIED_GHN_REPORTED = Filter.new(
    name: 'incidents.filter_by.verified_ghn_reported',
    field_name: 'verified_ghn_reported',
    type: 'multi_select',
    option_strings_source: 'lookup-verified-ghn-reported'
  )

  WEAPON_TYPE = Filter.new(
    name: 'incidents.filter_by.weapon_type',
    field_name: 'weapon_type',
    type: 'multi_select',
    option_strings_source: 'lookup-weapon-type'
  )

  FACILITY_IMPACT = Filter.new(
    name: 'incidents.filter_by.facility_impact',
    field_name: 'facility_impact',
    option_strings_source: 'lookup-facility-impact-type'
  )

  FACILITY_ATTACK_TYPE = Filter.new(
    name: 'incidents.filter_by.facility_attack_type',
    field_name: 'facility_attack_type',
    type: 'multi_select',
    option_strings_source: 'lookup-facility-attack-type'
  )

  CHILD_ROLE = Filter.new(
    name: 'incidents.filter_by.child_role',
    field_name: 'child_role',
    option_strings_source: 'lookup-combat-role-type'
  )

  ABDUCTION_PURPOSE_SINGLE = Filter.new(
    name: 'incidents.filter_by.abduction_purpose_single',
    field_name: 'abduction_purpose_single',
    type: 'multi_select',
    option_strings_source: 'lookup-abduction-purpose'
  )

  MILITARY_USE_TYPE = Filter.new(
    name: 'incidents.filter_by.military_use_type',
    field_name: 'military_use_type',
    option_strings_source: 'lookup-military-use-type'
  )

  TYPES_OF_AID_DISRUPTED_DENIAL = Filter.new(
    name: 'incidents.filter_by.types_of_aid_disrupted_denial',
    field_name: 'types_of_aid_disrupted_denial',
    option_strings_source: 'lookup-aid-service-type'
  )

  LATE_VERIFIED_VIOLATIONS = Filter.new(
    name: 'incidents.filter_by.late_verified_violations',
    field_name: 'has_late_verified_violations',
    options: I18n.available_locales.map do |locale|
      { locale => [{ id: 'true', display_name: I18n.t('true', locale: locale) }] }
    end.inject(&:merge)
  )

  PERPETRATOR_CATEGORY = Filter.new(
    name: 'incidents.filter_by.perpetrator_category',
    field_name: 'perpetrator_category',
    type: 'multi_select',
    option_strings_source: 'lookup-perpetrator-category-type'
  )

  class << self
    def filters(user, record_type)
      filters = case record_type
                when 'case' then case_filters(user)
                when 'incident' then incident_filters(user)
                when 'tracing_request' then tracing_request_filter(user)
                when 'registry_record' then registry_record_filter(user)
                end
      filters.map do |filter|
        hydrate_filter(filter, user, record_type)
      end
    end

    def hydrate_filter(filter, user, record_type)
      value = filter.clone
      value.with_options_for(user, record_type)
      value.resolve_type
      value
    end

    def reporting_location_config(role, record_type)
      case record_type
      when 'case'
        role.reporting_location_config
      when 'incident'
        role.incident_reporting_location_config
      else
        {}
      end
    end

    def reporting_location_data(role, record_type)
      reporting_location = reporting_location_config(role, record_type)

      {
        field: reporting_location&.field_key || ReportingLocation::DEFAULT_FIELD_KEY,
        labels: reporting_location&.label_keys,
        admin_level: reporting_location&.admin_level
      }
    end

    def case_filters(user)
      filters = []
      filters << FLAGGED_CASE
      filters << SOCIAL_WORKER if user.manager?
      filters += [MY_CASES, WORKFLOW]
      filters << AGENCY if user.admin?
      filters += [STATUS, AGE_RANGE, SEX] + user_based_filters(user) + [NO_ACTIVITY]
      filters << DATE_CASE if user.module?(PrimeroModule::CP)
      filters << ENABLED
      filters += photo_filters(user)
      filters
    end

    def user_based_filters(user)
      filters = []
      filters += approvals_filters(user)
      filters += field_based_filters(user)
      filters << RISK_LEVEL if user.module?(PrimeroModule::CP)
      filters << CURRENT_LOCATION if user.module?(PrimeroModule::CP)
      filters << AGENCY_OFFICE if user.module?(PrimeroModule::GBV)
      filters << USER_GROUP if user.module?(PrimeroModule::GBV) && user.user_group_filter?
      filters += reporting_location_filters(user)
      filters
    end

    def approvals_filters(user)
      filters = []
      filters << APPROVALS_STATUS_ASSESSMENT if user.can_approve_assessment?
      filters << APPROVALS_STATUS_CASE_PLAN if user.can_approve_case_plan?
      filters << APPROVALS_STATUS_CLOSURE if user.can_approve_closure?
      filters << APPROVALS_STATUS_ACTION_PLAN if user.can_approve_action_plan?
      filters << APPROVALS_STATUS_GBV_CLOSURE if user.can_approve_gbv_closure?
      filters
    end

    def field_based_filters(user)
      filter_fields = Field.where(name: CASE_FILTER_FIELD_NAMES).map { |f| [f.name, f] }.to_h
      filters = []
      filters += protection_concern_filter(user)
      filters += gbv_displacement_filter(user, filter_fields)
      filters += protection_status_filter(user, filter_fields)
      filters += urgent_protection_concern_filter(user, filter_fields)
      filters += type_of_risk_filter(user, filter_fields)
      filters
    end

    def protection_concern_filter(user)
      return [PROTECTION_CONCERNS] if user.can?(:view_protection_concerns_filter, Child)

      []
    end

    def gbv_displacement_filter(user, filter_fields)
      if user.module?(PrimeroModule::GBV) && visible?('gbv_displacement_status', filter_fields)
        return [GBV_DISPLACEMENT_STATUS]
      end

      []
    end

    def protection_status_filter(user, filter_fields)
      return [PROTECTION_STATUS] if visible?('protection_status', filter_fields) && user.module?(PrimeroModule::CP)

      []
    end

    def urgent_protection_concern_filter(user, filter_fields)
      if user.module?(PrimeroModule::CP) && visible?('urgent_protection_concern', filter_fields)
        return [URGENT_PROTECTION_CONCERN]
      end

      []
    end

    def type_of_risk_filter(user, filter_fields)
      return [TYPE_OF_RISK] if user.module?(PrimeroModule::CP) && visible?('type_of_risk', filter_fields)

      []
    end

    def reporting_location_filters(user)
      return [] unless user.module?(PrimeroModule::CP)

      role = user&.role
      return [] unless role

      filters = []
      filters << REPORTING_LOCATION.call(reporting_location_data(role, 'case')) if user.module?(PrimeroModule::CP)
      filters
    end

    def photo_filters(user)
      return [] unless user.module?(PrimeroModule::CP)

      role = user&.role
      return [] unless role

      permitted_form_ids = role.permitted_forms('case', true, false).pluck(:unique_id)
      return [] unless permitted_form_ids.include?('photos_and_audio')

      [PHOTO]
    end

    # rubocop:disable Metrics/AbcSize
    def incident_filters(user)
      filters = [FLAGGED_CASE] + violence_type_filter(user) + social_worker_filter(user)
      filters += agency_office_filter(user) + user_group_filter(user) + status_filters(user)
      filters += violation_filter(user)
      filters += [AGE_RANGE] if user.module?(PrimeroModule::GBV) || user.module?(PrimeroModule::CP)
      filters += children_verification_and_location_filters(user)
      filters += [INCIDENT_DATE] + unaccompanied_filter(user)
      filters += perpetrator_category_filters(user) + armed_force_group_filters(user)
      filters << ENABLED
      filters += mrm_incident_filters if user.module?(PrimeroModule::MRM)
      filters
    end
    # rubocop:enable Metrics/AbcSize

    def mrm_incident_filters
      [
        INDIVIDUAL_VIOLATIONS, INDIVIDUAL_AGE, INDIVIDUAL_SEX,
        DEPRIVED_LIBERTY_SECURITY_REASONS, REASONS_DEPRIVATION_LIBERTY,
        VICTIM_FACILTY_VICTIMS_HELD, TORTURE_PUNISHMENT_WHILE_DEPRIVATED_LIBERTY,
        WEAPON_TYPE, FACILITY_IMPACT, FACILITY_ATTACK_TYPE, CHILD_ROLE, ABDUCTION_PURPOSE_SINGLE,
        MILITARY_USE_TYPE, TYPES_OF_AID_DISRUPTED_DENIAL, RECORD_OWNER, AGENCY
      ]
    end

    def violence_type_filter(user)
      user.module?(PrimeroModule::GBV) ? [VIOLENCE_TYPE] : []
    end

    def social_worker_filter(user)
      user.manager? ? [SOCIAL_WORKER] : []
    end

    def agency_office_filter(user)
      user.module?(PrimeroModule::GBV) ? [AGENCY_OFFICE] : []
    end

    def user_group_filter(user)
      user.module?(PrimeroModule::GBV) && user.user_group_filter? ? [USER_GROUP] : []
    end

    def status_filters(user)
      user.module?(PrimeroModule::MRM) ? [INCIDENT_STATUS] : [STATUS]
    end

    def violation_filter(user)
      return [] unless user.module?(PrimeroModule::MRM)

      [VIOLATION_FILTER]
    end

    def children_verification_and_location_filters(user)
      filters = []

      if user.module?(PrimeroModule::MRM)
        filters = [CHILDREN, VERIFICATION_STATUS, LATE_VERIFIED_VIOLATIONS, VERIFIED_GHN_REPORTED]
      end

      filters += location_filters(user)
      filters
    end

    def location_filters(user)
      location_filters = [INCIDENT_LOCATION]
      return location_filters unless user.module?(PrimeroModule::MRM)

      role = user&.role
      location_filters << REPORTING_LOCATION.call(reporting_location_data(role, 'incident'))
      location_filters
    end

    def unaccompanied_filter(user)
      user.module?(PrimeroModule::GBV) ? [UNACCOMPANIED_PROTECTION_STATUS] : []
    end

    def perpetrator_category_filters(user)
      user.module?(PrimeroModule::MRM) ? [PERPETRATOR_CATEGORY] : []
    end

    def armed_force_group_filters(user)
      user.module?(PrimeroModule::MRM) ? [ARMED_FORCE_GROUP_PARTY] : []
    end

    def tracing_request_filter(user)
      filters = []
      filters << FLAGGED_CASE
      filters << SOCIAL_WORKER if user.manager?
      filters << INQUIRY_DATE
      filters << TRACING_REQUEST_STATUS
      filters << SEPARATION_LOCATION
      filters << SEPARATION_CAUSE
      filters << ENABLED
      filters
    end

    def registry_record_filter(_user)
      filters = []
      filters << FLAGGED_CASE
      filters << REGISTRY_STATUS
      filters << ENABLED
      filters << CURRENT_LOCATION
      filters << DATE_REGISTRY
      filters
    end

    private

    def visible?(field_name, filter_fields)
      field = filter_fields[field_name]
      field.present? && field.visible?
    end
  end

  def initialize(args = {})
    super(args)
  end

  def owned_by_options(opts = {})
    managed_user_names = opts[:user].managed_user_names
    self.options = managed_user_names.map { |user_name| { id: user_name, display_name: user_name } }
  end

  def workflow_options(opts = {})
    user_modules = opts[:user].modules_for_record_type(opts[:record_type])
    self.options = Child.workflow_statuses(user_modules)
  end

  def owned_by_agency_id_options(opts = {})
    managed_user_names = opts[:user].managed_user_names
    agencies = User.agencies_for_user_names(managed_user_names).where(disabled: false)
    self.options = I18n.available_locales.map do |locale|
      locale_options = agencies.map do |agency|
        { id: agency.unique_id, display_name: agency.name(locale) }
      end
      { locale => locale_options }
    end.inject(&:merge)
  end

  def age_options(_opts = {})
    self.options = SystemSettings.primary_age_ranges.map do |age_range|
      { id: age_range.to_s, display_name: age_range.to_s }
    end
  end
  alias individual_age_options age_options

  def owned_by_groups_options(_opts = {})
    enabled_user_groups = UserGroup.where(disabled: false).map do |user_group|
      { id: user_group.unique_id, display_name: user_group.name }
    end

    self.options = I18n.available_locales.map do |locale|
      { locale => enabled_user_groups }
    end.inject(&:merge)
  end

  def cases_by_date_options(opts = {})
    self.options = I18n.available_locales.map do |locale|
      locale_options = [registration_date_options(locale), assessment_requested_on_options(locale),
                        date_case_plan_options(locale), date_closure_options(locale)]
      date_label = opts[:user].module?(PrimeroModule::GBV) ? 'created_at' : 'date_of_creation'
      locale_options << created_at_options(locale, date_label)
      { locale => locale_options }
    end.inject(&:merge)
  end

  def registration_date_options(locale)
    {
      id: 'registration_date',
      display_name: I18n.t('children.selectable_date_options.registration_date', locale: locale)
    }
  end

  def assessment_requested_on_options(locale)
    {
      id: 'assessment_requested_on',
      display_name: I18n.t('children.selectable_date_options.assessment_requested_on', locale: locale)
    }
  end

  def date_case_plan_options(locale)
    {
      id: 'date_case_plan',
      display_name: I18n.t('children.selectable_date_options.date_case_plan_initiated', locale: locale)
    }
  end

  def date_closure_options(locale)
    {
      id: 'date_closure',
      display_name: I18n.t('children.selectable_date_options.closure_approved_date', locale: locale)
    }
  end

  def created_at_options(locale, date_label)
    {
      id: 'created_at',
      display_name: I18n.t("children.selectable_date_options.#{date_label}", locale: locale)
    }
  end

  def incidents_by_date_options(opts = {})
    self.options = I18n.available_locales.map do |locale|
      locale_options = []
      locale_options << date_of_first_report_options(locale) if opts[:user].module?(PrimeroModule::GBV)
      if opts[:user].module?(PrimeroModule::MRM)
        locale_options << date_of_first_report_options(locale, 'mrm_date_of_first_report')
        locale_options << ctfmr_verified_date_options(locale)
      end
      locale_options << incident_date_derived_options(locale)
      { locale => locale_options }
    end.inject(&:merge)
  end

  def date_of_first_report_options(locale, label_key = 'date_of_first_report')
    {
      id: 'date_of_first_report',
      display_name: I18n.t("incidents.selectable_date_options.#{label_key}", locale: locale)
    }
  end

  def mrm_date_of_first_report_options(locale)
    {
      id: 'date_of_first_report',
      display_name: I18n.t('incidents.selectable_date_options.mrm_date_of_first_report', locale: locale)
    }
  end

  def ctfmr_verified_date_options(locale)
    {
      id: 'ctfmr_verified_date',
      display_name: I18n.t('incidents.selectable_date_options.ctfmr_verified_date', locale: locale)
    }
  end

  def incident_date_derived_options(locale)
    {
      id: 'incident_date_derived',
      display_name: I18n.t('incidents.selectable_date_options.incident_date_derived', locale: locale)
    }
  end

  def registry_records_by_date_options(_opts = {})
    self.options = I18n.available_locales.map do |locale|
      locale_options = [{
        id: 'registration_date',
        display_name: I18n.t('registry_records.selectable_date_options.registration_date', locale: locale)
      }]
      { locale => locale_options }
    end.inject(&:merge)
  end

  def approval_status_options
    self.options = I18n.available_locales.map do |locale|
      {
        locale => [
          Approval::APPROVAL_STATUS_PENDING, Approval::APPROVAL_STATUS_APPROVED,
          Approval::APPROVAL_STATUS_REJECTED
        ].map do |status|
          { id: status, display_name: I18n.t("cases.filter_by.approvals.#{status}", locale: locale) }
        end
      }
    end.inject(&:merge)
  end

  def with_options_for(user, record_type)
    if %w[approval_status_assessment approval_status_case_plan approval_status_closure
          approval_status_action_plan approval_status_gbv_closure].include? field_name
      approval_status_options
    elsif %w[
      owned_by workflow owned_by_agency_id age owned_by_groups cases_by_date incidents_by_date
      registry_records_by_date individual_age
    ].include? field_name
      opts = { user: user, record_type: record_type }
      send("#{field_name}_options", opts)
    end
  end

  def resolve_type
    return if type.present?

    if options.blank?
      self.type = 'checkbox'
      return
    end

    options_length = options.is_a?(Array) ? options.length : options[I18n.default_locale].length
    options_length_to_type(options_length)
  end

  def options_length_to_type(options_length)
    case options_length
    when 1
      self.type = 'toggle'
    when 2, 3
      self.type = 'multi_toggle'
    else
      self.type = 'checkbox'
    end
  end

  def inspect
    "Filter(name: #{name}, field_name: #{field_name}, type: #{type})"
  end
end
# rubocop:enable Metrics/ClassLength
