# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# The truth of it is, this is a long class.
# Just the same, it shouldn't exceed 300 lines (250 lines of active code).

# TODO Update the referencing comments after properly updating the files
# TODO Add Explanatory Comments
# TODO Create Concerns so that this file does not exceed 300 lines, More or less

# The central Primero model object that represents an individual's case.
# In spite of the name, this will represent adult cases as well.
class Child < ApplicationRecord
  RISK_LEVEL_HIGH = 'high'
  RISK_LEVEL_NONE = 'none'
  NAME_FIELDS     = %w[name name_nickname name_other].freeze

  self.table_name = 'cases'

  def self.parent_form
    'case'
  end

  # This module updates photo_keys with the before_save callback and needs to
  # run before the before_save callback in Historical to make the history
  include Record
  include Searchable
  include Historical
  include BIADerivedFields
  include CareArrangements
  include UNHCRMapping
  include Ownable
  include AutoPopulatable
  include Serviceable
  include Reopenable
  include Workflow
  include Flaggable
  include Transitionable
  include Approvable
  include Alertable
  include Attachable
  include Noteable
  include EagerLoadable
  include Webhookable
  include Kpi::GBVChild
  include DuplicateIdAlertable
  include FollowUpable
  include LocationCacheable

  # Accessors
  store_accessor(
    :data,
    :case_id, :case_id_code, :case_id_display,
    :nickname, :name, :protection_concerns, :consent_for_tracing, :hidden_name,
    :name_first, :name_middle, :name_last, :name_nickname, :name_other,
    :registration_date, :age, :estimated, :date_of_birth, :sex, :address_last,
    :risk_level, :date_case_plan, :case_plan_due_date, :date_case_plan_initiated,
    :date_closure, :assessment_due_date, :assessment_requested_on,
    :followup_subform_section, :protection_concern_detail_subform_section,
    :disclosure_other_orgs,
    :ration_card_no, :icrc_ref_no, :unhcr_id_no, :unhcr_individual_no, :un_no, :other_agency_id,
    :survivor_code_no, :national_id_no, :other_id_no, :biometrics_id, :family_count_no, :dss_id, :camp_id, :cpims_id,
    :tent_number, :nfi_distribution_id,
    :nationality, :ethnicity, :religion, :language, :sub_ethnicity_1, :sub_ethnicity_2, :country_of_origin,
    :displacement_status, :marital_status, :disability_type, :incident_details,
    :location_current, :tracing_status, :name_caregiver,
    :registry_id_display, :registry_name, :registry_no, :registry_location_current,
    :urgent_protection_concern, :child_preferences_section, :family_details_section, :care_arrangements_section,
    :duplicate, :cp_case_plan_subform_case_plan_interventions, :has_case_plan
  )

  # Associations
  has_many   :incidents      ,                      foreign_key: :incident_case_id
  has_many   :matched_traces , class_name: 'Trace', foreign_key: 'matched_case_id'
  has_many   :duplicates     , class_name: 'Child', foreign_key: 'duplicate_case_id'
  belongs_to :duplicate_of   , class_name: 'Child', foreign_key: 'duplicate_case_id', optional: true
  belongs_to :registry_record,                      foreign_key: :registry_record_id, optional: true

  # Scopes
  scope :by_date_of_birth, -> { where.not('data @> ?', { date_of_birth: nil }.to_json) }

  #? What purpose does this scope have relating to Graphs
  # Filter records from a database table based on two conditions:
  # 1) The data column in the table must contain a key-value pair where
    # the key is "owned_by_location," and
    # the value matches the pattern "SIN%."
  # 2 ) The data column must contain a JSONB object with a specific key-value pair, which is represented by
    # the hash {'is_this_a_significant_harm_case__b343242' => 'yes_174476'} converted to JSON.
  scope :with_province, -> (user) {
    where( "data ->> :key LIKE :value", :key => "owned_by_location", :value => "SIN%" ).where('risk_level', 'high')
  }

  #TODO see if these scopes are work correctly
  # Cases requiring Alternative Care Placement Services
  scope :with_department, ->(agency) { where("data @> ?", { owned_by_agency_id: agency }.to_json) }
  #TODO see if these scopes are still requreid. or are They used correctly with this nationality_b80911e attribute
  # Cases requiring Alternative Care Placement Services
  scope :check_for_alternate_care_placement_with_user, -> (username) { find_by_sql("SELECT * FROM cases
    WHERE data->>'nationality_b80911e' IS NOT NULL AND
    (data->>'owned_by' = '#{username}')::boolean is true") }
  #TODO see if these scopes are still requreid. or are They used correctly with this nationality_b80911e attribute
  # Cases requiring Alternative Care Placement Services
  scope :check_for_alternate_care_placement, -> { find_by_sql("SELECT * FROM cases WHERE data->>'nationality_b80911e' IS NOT NULL") }

  def self.sortable_text_fields
    %w[name case_id_display national_id_no registry_no]
  end

  def self.filterable_id_fields
    # The fields family_count_no and dss_id are hacked in only because of Bangladesh
    # The fields camp_id, tent_number and nfi_distribution_id are hacked in only because of Iraq
    %w[ unique_identifier short_id case_id_display case_id
        ration_card_no icrc_ref_no rc_id_no unhcr_id_no unhcr_individual_no un_no
        other_agency_id survivor_code_no national_id_no other_id_no biometrics_id
        family_count_no dss_id camp_id tent_number nfi_distribution_id oscar_number registry_no ]
  end

  def self.quicksearch_fields
    filterable_id_fields + NAME_FIELDS
  end

  def self.summary_field_names
    common_summary_fields + %w[
      case_id_display name survivor_code_no age sex registration_date
      hidden_name workflow case_status_reopened module_id registry_record_id
    ]
  end

  def self.alert_count_self(current_user)
    records_owned_by = open_enabled_records.owned_by(current_user.user_name).ids
    # TODO: Once relation between transition and record is fixee, use joins(:transitions)
    records_referred_users = open_enabled_records.joins(
      "INNER JOIN transitions ON transitions.record_type = 'Child' AND (transitions.record_id)::uuid = cases.id"
    ).where(transitions:
      {
        type: Referral.name,
        status: [Transition::STATUS_INPROGRESS, Transition::STATUS_ACCEPTED],
        transitioned_to: current_user.user_name
      }).ids
    (records_referred_users + records_owned_by).uniq.count
  end

  def self.child_matching_field_names
    MatchingConfiguration.matchable_fields('case', false).pluck(:name) | MatchingConfiguration::DEFAULT_CHILD_FIELDS
  end

  def self.family_matching_field_names
    MatchingConfiguration.matchable_fields('case', true).pluck(:name) | MatchingConfiguration::DEFAULT_INQUIRER_FIELDS
  end

  def self.api_path
    '/api/v2/cases'
  end

  searchable do
    filterable_id_fields.each { |f| string( "#{f}_filterable", as: "#{f}_filterable_sci") { data[f] } }
    sortable_text_fields.each { |f| string( "#{f}_sortable"  , as: "#{f}_sortable_sci"  ) { data[f] } }

    Child.child_matching_field_names.each { |f| text_index(f, suffix: 'matchable') }
    Child.family_matching_field_names.each do |f|
      text_index(f, suffix: 'matchable', subform_field_name: 'family_details_section')
    end

    quicksearch_fields.each { |f| text_index(f) }

    %w[registration_date date_case_plan_initiated assessment_requested_on date_closure].each { |f| date(f) }
    %w[estimated urgent_protection_concern consent_for_tracing has_case_plan].each do |f|
      boolean(f) { data[f] == true || data[f] == 'true' }
    end
    %w[day_of_birth age].each { |f| integer(f) }
    %w[id status sex current_care_arrangements_type].each { |f| string(f, as: "#{f}_sci") }

    string :risk_level, as: 'risk_level_sci' do
      risk_level.present? ? risk_level : RISK_LEVEL_NONE
    end
    string :protection_concerns, multiple: true

    date(:assessment_due_dates, multiple: true) { Tasks::AssessmentTask.from_case(self).map(&:due_date) }
    date(:case_plan_due_dates , multiple: true) { Tasks::CasePlanTask.from_case(self).map(&:due_date) }
    date(:followup_due_dates  , multiple: true) { Tasks::FollowUpTask.from_case(self).map(&:due_date) }

    boolean(:has_incidents) { incidents.size.positive? }

    string :data do
      data
    end
  end

  # Validations
  validate :validate_date_of_birth

  # Callbacks
  before_save   :sync_protection_concerns
  before_save   :auto_populate_name
  before_save   :stamp_registry_fields
  before_save   :calculate_has_case_plan
  before_create :hide_name
  after_save    :save_incidents

  class << self
    alias super_new_with_user new_with_user
    def new_with_user(user, data = {})
      new_case = super_new_with_user(user, data).tap do |local_case|
        local_case.registry_record_id ||= local_case.data.delete('registry_record_id')
      end
      new_case
    end
  end

  alias super_defaults defaults
  def defaults
    super_defaults
    self.registration_date ||= Date.today
    self.notes_section ||= []
  end

  def self.report_filters
    [
      { 'attribute' => 'status'      , 'value' => [STATUS_OPEN] },
      { 'attribute' => 'record_state', 'value' => ['true']      }
    ]
  end

  # TODO: does this need reporting location???
  # TODO: does this need the reporting_location_config field key
  # TODO: refactor with nested
  def self.minimum_reportable_fields
    {
      'boolean' => ['record_state'],
      'string' => %w[
        status sex risk_level owned_by_agency_id owned_by workflow workflow_status risk_level consent_reporting
      ],
      'multistring' => %w[associated_user_names associated_user_agencies owned_by_groups],
      'date' => ['registration_date'],
      'integer' => ['age'],
      'location' => %w[owned_by_location location_current]
    }
  end

  def self.nested_reportable_types
    [ReportableProtectionConcern, ReportableService, ReportableFollowUp]
  end

  def validate_date_of_birth
    return unless date_of_birth.present? && (!date_of_birth.is_a?(Date) || date_of_birth.year > Date.today.year)

    errors.add(:date_of_birth, I18n.t('errors.models.child.date_of_birth'))
  end

  alias super_update_properties update_properties
  def update_properties(user, data)
    build_or_update_incidents(user, (data.delete('incident_details') || []))
    self.registry_record_id = data.delete('registry_record_id') if data.key?('registry_record_id')
    self.mark_for_reopen = @incidents_to_save.present?
    super_update_properties(user, data)
  end

  def build_or_update_incidents(user, incidents_data)
    return unless incidents_data

    @incidents_to_save = incidents_data.map do |incident_data|
      incident = Incident.find_by(id: incident_data['unique_id'])
      incident ||= IncidentCreationService.incident_from_case(self, incident_data, module_id, user)
      unless incident.new_record?
        incident_data.delete('unique_id')
        incident.data = RecordMergeDataHashService.merge_data(incident.data, incident_data) unless incident.new_record?
      end
      incident.has_changes_to_save? ? incident : nil
    end.compact
  end

  def save_incidents
    return unless @incidents_to_save

    Incident.transaction do
      @incidents_to_save.each(&:save!)
    end
  end

  def to_s
    name.present? ? "#{name} (#{unique_identifier})" : unique_identifier
  end

  def auto_populate_name
    # This 2 step process is necessary because you don't want to overwrite self.name if auto_populate is off
    a_name = auto_populate('name')
    self.name = a_name if a_name.present?
  end

  def hide_name
    self.hidden_name = true if module_id == PrimeroModule::GBV
  end

  def set_instance_id
    system_settings = SystemSettings.current
    self.case_id ||= unique_identifier
    self.case_id_code ||= auto_populate('case_id_code', system_settings)
    self.case_id_display ||= create_case_id_display(system_settings)
  end

  def create_case_id_code(system_settings)
    separator = system_settings&.case_code_separator.present? ? system_settings.case_code_separator : ''
    id_code_parts = []
    if system_settings.present? && system_settings.case_code_format.present?
      system_settings.case_code_format.each { |cf| id_code_parts << PropertyEvaluator.evaluate(self, cf) }
    end
    id_code_parts.reject(&:blank?).join(separator)
  end

  def create_case_id_display(system_settings)
    [case_id_code, short_id].compact.join(auto_populate_separator('case_id_code', system_settings))
  end

  def display_id
    case_id_display
  end

  def day_of_birth
    return nil unless date_of_birth.is_a? Date

    AgeService.day_of_year(date_of_birth)
  end

  def calculate_has_case_plan
    interventions = cp_case_plan_subform_case_plan_interventions || []
    self.has_case_plan = interventions.any? do |intervention|
      intervention['intervention_service_to_be_provided'].present? || intervention['intervention_service_goal'].present?
    end

    has_case_plan
  end

  def sync_protection_concerns
    protection_concerns = self.protection_concerns || []
    from_subforms = protection_concern_detail_subform_section&.map { |pc| pc['protection_concern_type'] }&.compact || []
    self.protection_concerns = (protection_concerns + from_subforms).uniq
  end

  def stamp_registry_fields
    return unless changes_to_save.key?('registry_record_id')

    self.registry_id_display = registry_record&.registry_id_display
    self.registry_name = registry_record&.name
    self.registry_no = registry_record&.registry_no
    self.registry_location_current = registry_record&.location_current
  end

  def match_criteria
    match_criteria = data.slice(*Child.child_matching_field_names).compact
    match_criteria = match_criteria.merge(
      Child.family_matching_field_names.map do |field_name|
        [field_name, values_from_subform('family_details_section', field_name)]
      end.to_h
    )
    match_criteria = match_criteria.transform_values { |v| v.is_a?(Array) ? v.join(' ') : v }
    match_criteria.select { |_, v| v.present? }
  end

  def matches_to
    Trace
  end

  def associations_as_data(current_user = nil)
    return @associations_as_data if @associations_as_data

    incident_details = RecordScopeService.scope_with_user(incidents, current_user).map do |incident|
      incident.data&.reject { |_, v| RecordMergeDataHashService.array_of_hashes?(v) }
    end.compact || []
    @associations_as_data = { 'incident_details' => incident_details }
  end

  def associations_as_data_keys
    %w[incident_details]
  end

  # Graphs
  # =========================================================================================================================================

  # protection_concerns_services_stats
  # Graph for 'Percentage of Childern who received Child Protection Services'
    # (No of Cases by Protection Concern that have recieved the Service) / (Total Number of Cases by Protection Concern)
  #TODO Need get Records based on Graph Roles
  def self.protection_concern_stats(user)
    name = user.role.name

    # Roles allowed
    # Social Case Worker (scw)
      # View his own cases
    # Psychologist (Psy)
      # View his own cases
    # Child Helpline Officer (cho)
      # View his own cases
    # Referrals
      # View cases referred to him
    # Child Protection Officer (cpo)
      # View Cases of Social Case Worker, Psychologist and Child Helpline Operator working in his user group (Same District)
    # Member CPWC
      # View Cases of all Districts (Provincial data)

    return { permission: false } unless name.in? ['CPO', 'Referral', 'CPI In-charge', 'CP Manager', 'Superuser']

    # Protection Concern Lookup values
    # [
    #   {"id"=>"other"                       , "en"=>"Violence"            },
    #   {"id"=>"exploitation_b9352d1"        , "en"=>"Exploitation"        },
    #   {"id"=>"neglect_a7b48b2"             , "en"=>"Neglect"             },
    #   {"id"=>"harmful_practice_s__d1f7955" , "en"=>"Harmful practice(s)" },
    #   {"id"=>"other_b637c39"               , "en"=>"Abuse"               },
    #   {"id"=>"other_7b13407"               , "en"=>"Other"               }
    # ]

    stats = {
      violence:          { cases: 0 , percentage: 0 } , # other
      exploitation:      { cases: 0 , percentage: 0 } , # exploitation_b9352d1
      neglect:           { cases: 0 , percentage: 0 } , # neglect_a7b48b2
      harmful_practices: { cases: 0 , percentage: 0 } , # harmful_practice_s__d1f7955
      abuse:             { cases: 0 , percentage: 0 } , # other_b637c39
      other:             { cases: 0 , percentage: 0 } , # other_7b13407
    }

    # Getting Total Number of Opened Cases
    total_case_count = Child.get_childs(user, "high", "registered").count

    # Calculate Stats
    Child.get_childs(user, "high").each do |child|
      #TODO Ask what's response_to_goal_cd94ee4
        #? Is it 'response_on_referred_case_da89310' ?
      #TODO Ask what's not_applicable_445274
        #? Is the field still present ?

        # child.data["response_on_referred_case_da89310"] is an array containing a hash
        response_on_referred_case = child.data["response_on_referred_case_da89310"]
        # has_the_service_been_provided__23eb99e returns a string that is either "true" or "false"
      if response_on_referred_case && response_on_referred_case[0]["has_the_service_been_provided__23eb99e"] == "true"
        # child.data["protection_concerns"] returns an array of strings, Each specifing a Protection Concern
        if child.data["protection_concerns"].include?("other")
          stats[:violence][:cases] += 1
        end

        if child.data["protection_concerns"].include?("exploitation_b9352d1")
          stats[:exploitation][:cases] += 1
        end

        if child.data["protection_concerns"].include?("neglect_a7b48b2")
          stats[:neglect][:cases] += 1
        end

        if child.data["protection_concerns"].include?("harmful_practice_s__d1f7955")
          stats[:harmful_practices][:cases] += 1
        end

        if child.data["protection_concerns"].include?("other_b637c39")
          stats[:abuse][:cases] += 1
        end

        if child.data["protection_concerns"].include?("other_b637c39")
          stats[:other][:cases] += 1
        end
      end
    end.count

    # Get Percentages
    stats.each do |key, value|
      value[:percentage] = get_percentage(value[:cases], total_case_count) unless total_case_count.eql?(0)
    end

    total_cases =  {
      violence:          { cases: stats[:violence          ][:cases] , percentage: stats[:violence          ][:percentage]} ,
      exploitation:      { cases: stats[:exploitation      ][:cases] , percentage: stats[:exploitation      ][:percentage]} ,
      neglect:           { cases: stats[:neglect           ][:cases] , percentage: stats[:neglect           ][:percentage]} ,
      harmful_practices: { cases: stats[:harmful_practices ][:cases] , percentage: stats[:harmful_practices ][:percentage]} ,
      abuse:             { cases: stats[:abuse             ][:cases] , percentage: stats[:abuse             ][:percentage]} ,
      other:             { cases: stats[:other             ][:cases] , percentage: stats[:other             ][:percentage]} ,
    }

    total_cases
  end

  # resolved_cases_by_gender_and_types_of_violence_stats
  # Graph for 'Closed Cases by Sex and Protection Concern'
    # Total Number of Closed Cases by Sex, Where the "What is reason for closing this case" contains dropdown values (Each Reason Separate bar).
  #TODO Need get Records based on Graph Roles
  def self.resolved_cases_by_gender_and_types_of_violence(user)

    # Roles allowed
    #  Social Case Worker (scw)
      # View his own cases
    # Psychologist (Psy)
      # View his own cases
    # Child Helpline Officer (cho)
      # View his own cases
    # Referrals
      # View cases referred to him
    # Child Protection Officer (cpo)
      # View Cases of Social Case Worker, Psychologist and Child Helpline Operator working in his user group (Same District)
    # Member CPWC
      # View Cases of all Districts (Provincial data)

    return { permission: false } unless user.role.name.in? ['CPI In-charge', 'CPO', 'CP Manager', 'Superuser']

      # What is reason for closing this case? Lookup Values
      # {"id"=> "case_goals_all_met_811860"      , "en"=> "Case goals all met"      },
      # {
      #   "id" => "case_goals_substantially_met_and_there_is_no_further_child_protection_concern_376876",
      #   "en" => "Case goals substantially met and there is no further child protection concern"
      # },
      # {"id"=> "child_reached_adulthood_490887" , "en"=> "Child reached adulthood" },
      # {"id"=> "child_refuses_services_181533"  , "en"=> "Child refuses services"  },
      # {"id"=> "safety_of_child_362513"         , "en"=> "Safety of child"         },
      # {"id"=> "death_of_child_285462"          , "en"=> "Death of child"          },
      # {"id"=> "other_100182"                   , "en"=> "Other"                   }

    result = {}

    #TODO May need to modify this to make the stats keys simple without the numbers at the end.
    #TODO Will have to modify the jbuilder view code if I do that.
    result["stats"] =  {
      case_goals_all_met_811860:           { male: 0, female: 0, transgender: 0 }, # case_goals_all_met

      case_goals_substantially_met_and_there_is_no_further_child_protection_concern_376876: {
        male: 0, female: 0, transgender: 0
      }, # case_goals_substantially_met

      child_reached_adulthood_490887:      { male: 0, female: 0, transgender: 0 }, # child_reached_adulthood
      child_refuses_services_181533:       { male: 0, female: 0, transgender: 0 }, # child_refuses_services
      safety_of_child_362513:              { male: 0, female: 0, transgender: 0 }, # safety_of_child
      death_of_child_285462:               { male: 0, female: 0, transgender: 0 }, # death_of_child
      other_100182:                        { male: 0, female: 0, transgender: 0 }, # other
    }

    get_resolved_cases_for_role(user, "high").each do |child|
      gender = child.data["sex"]
      next unless gender

      if child.data["case_goals_all_met_811860"].present?
        result["stats"][:case_goals_all_met_811860][gender.to_sym] += 1
      end

      if child.data["case_goals_substantially_met_and_there_is_no_further_child_protection_concern_376876"].present?
        result["stats"][:case_goals_substantially_met_and_there_is_no_further_child_protection_concern_376876][gender.to_sym] += 1
      end

      if child.data["child_reached_adulthood_490887"].present?
        result["stats"][:child_reached_adulthood_490887][gender.to_sym] += 1
      end

      if child.data["child_refuses_services_181533"].present?
        result["stats"][:child_refuses_services_181533][gender.to_sym] += 1
      end

      if child.data["safety_of_child_362513"].present?
        result["stats"][:safety_of_child_362513][gender.to_sym] += 1
      end

      if child.data["death_of_child_285462"].present?
        result["stats"][:death_of_child_285462][gender.to_sym] += 1
      end

      if child.data["other_100182"].present?
        result["stats"][:other_100182][gender.to_sym] += 1
      end
    end

    result
  end

  # cases_referral_to_agency_stats
  # Graph for 'Cases Referral (To Agency )'
    # Total Number of Open Referrals cases Where Referred to Agency, Desegregated by Sex
  #TODO Need get Records based on Graph Roles
  #TODO Logic needs to be modified, There is no Agency Field Under referal Form, Ask for that.
  def self.cases_referral_to_agency(user)
    # Roles allowed
    # Social Case Worker (scw)
      # View his own cases
    # Psychologist (Psy)
      # View his own cases
    # Child Helpline Officer (cho)
      # View his own cases
    # Referrals
      # View cases referred to him
    # Child Protection Officer (cpo)
      # View Cases of Social Case Worker, Psychologist and Child Helpline Operator working in his user group (Same District)
    # Member CPWC
      # View Cases of all Districts (Provincial data)

    return { permission: false } unless user.role.name.in? ['CPO', 'CPI In-charge', 'Superuser']

    stats = {}

    Agency.all.each do |agency|
      stats.merge!({ agency.name => 0 })
    end

    Child.get_reffered_cases.each do |child|
      child.data["assigned_user_names"].each do |reffer|
        dept = Agency.find(User.find_by(user_name: reffer).agency_id).name
        stats[dept] += 1
      end
    end

    stats
  end

  #TODO Can't get any records or stats, May be issue with not having enough records
  #TODO Need get Records based on Graph Roles
  # alternative_care_placement_by_gender
  # Graph for 'Cases requiring Alternative Care Placement Services'
    # Total Number of Open Cases Open Where Nationality =
      # Pakistani || Afghani || Irani
    # Desegregated by Sex
  def self.alternative_care_placement_by_gender(user)
    # Roles allowed
    #  Social Case Worker (scw)
      # View his own cases
    # Psychologist (Psy)
      # View his own cases
    # Child Helpline Officer (cho)
      # View his own cases
    # Referrals
      # View cases referred to him
    # Child Protection Officer (cpo)
      # View Cases of Social Case Worker, Psychologist and Child Helpline Operator working in his user group (Same District)
    # Member CPWC
      # View Cases of all Districts (Provincial data)

    role_name = user.role.name

    return { permission: false } unless role_name.in? ['CPO', 'CPI In-charge', 'Superuser']

    stats = {
      male: 0,
      female: 0,
      transgender: 0
    }

    alternate_cases = role_name.eql?("Superuser") ? check_for_alternate_care_placement_with_user(user.user_name) : with_department(user.agency.unique_id).check_for_alternate_care_placement

    alternate_cases.each do |child|
      gender = child.data["sex"]

      case gender
      when "male"
        stats[:male] += 1
      when "female"
        stats[:female] += 1
      else
        stats[:transgender] += 1
      end
    end

    stats_final = [stats[:male], stats[:female], stats[:transgender]]
    stats_final
  end

  #TODO Need get Records based on Graph Roles
  #TODO May need to modify the logic a bit
  # Form: Basic Information,
    # Field: Sex Database: sex
  # Field: registration_date
    # Database Name: registration_date
  # Form: Closure
    # Field: date_closure
      # Database Name: date_closure

  # Graph for 'Registered and Closed Cases by Month'
    # Total Number of Registered and Closed Cases Gender wise (by User) – Last 12 months
  def self.month_wise_registered_and_resolved_cases(user)
    # Roles allowed
    # Social Case Worker (scw)
      # View his own cases
    # Psychologist (Psy)
      # View his own cases
    # Child Helpline Officer (cho)
      # View his own cases
    # Referrals
      # View cases referred to him
    # Child Protection Officer (cpo)
      # View Cases of Social Case Worker, Psychologist and Child Helpline Operator working in his user group (Same District)
    # Member CPWC
      # View Cases of all Districts (Provincial data)

    name = user.role.name

    return { permission: false } unless name.in? ['CPO', 'Referral', 'CPI In-charge', 'CP Manager', 'Superuser']

    stats = {
      "Resolved" => hash_return_for_month_wise_api,
      "Registered" => hash_return_for_month_wise_api
    }

    Child.get_childs(user).each do |child|
      day = child.created_at
      next unless day.to_date.in? (Date.today.prev_year..Date.today)

      key = day.strftime("%B")[0,3]
      gender = (child.data["sex"].in? ["male", "female"]) ? child.data["sex"] : "transgender"

      if child.age.present? && child.data["status"].eql?("open")
        stats["Registered"][key][gender] += 1
        stats["Registered"][key]["total"] += 1
      elsif child.data["status"].eql?("closed")
        stats["Resolved"][key][gender] += 1
        stats["Resolved"][key]["total"] += 1
      end
    end

    stats
  end

  #TODO Can't get any records or stats, May be issue with not having enough records
  #TODO Need get Records based on Graph Roles
  # Graph for 'Significant Harm Cases by Protection Concern'
    # Total No of Open Cases by Protection Concern Where the Risk Level = High
  def self.significant_harm_cases_registered_by_age_and_gender(user)
    name = user.role.name

    # Social Case Worker (scw)
      # View his own cases
    #  Psychologist (Psy)
      # View his own cases
    # Child Helpline Officer (cho)
      # View his own cases
    # Referrals
      # View cases referred to him
    # Child Protection Officer (cpo)
      # View Cases of Social Case Worker, Psychologist and Child Helpline Operator working in  his user group (Same District)
    # Member CPWC
      # View Cases of all Districts (Provincial data)

    return { permission: false } unless name.in? ['CPO', 'CPI In-charge', 'Superuser']

    stats = {
      violence:          { cases: 0 , percentage: 0 } , # other
      exploitation:      { cases: 0 , percentage: 0 } , # exploitation_b9352d1
      neglect:           { cases: 0 , percentage: 0 } , # neglect_a7b48b2
      harmful_practices: { cases: 0 , percentage: 0 } , # harmful_practice_s__d1f7955
      abuse:             { cases: 0 , percentage: 0 } , # other_b637c39
      other:             { cases: 0 , percentage: 0 } , # other_7b13407
    }

    Child.get_childs(user, "high").each do |child|
        # child.data["protection_concerns"] returns an array of strings, Each specifing a Protection Concern
        if child.data["protection_concerns"].include?("other")
          stats[:violence][:cases] += 1
        end

        if child.data["protection_concerns"].include?("exploitation_b9352d1")
          stats[:exploitation][:cases] += 1
        end

        if child.data["protection_concerns"].include?("neglect_a7b48b2")
          stats[:neglect][:cases] += 1
        end

        if child.data["protection_concerns"].include?("harmful_practice_s__d1f7955")
          stats[:harmful_practices][:cases] += 1
        end

        if child.data["protection_concerns"].include?("other_b637c39")
          stats[:abuse][:cases] += 1
        end

        if child.data["protection_concerns"].include?("other_b637c39")
          stats[:other][:cases] += 1
        end
    end

    total_cases =  {
      violence:          { cases: stats[:violence          ][:cases] , percentage: stats[:violence          ][:percentage]} ,
      exploitation:      { cases: stats[:exploitation      ][:cases] , percentage: stats[:exploitation      ][:percentage]} ,
      neglect:           { cases: stats[:neglect           ][:cases] , percentage: stats[:neglect           ][:percentage]} ,
      harmful_practices: { cases: stats[:harmful_practices ][:cases] , percentage: stats[:harmful_practices ][:percentage]} ,
      abuse:             { cases: stats[:abuse             ][:cases] , percentage: stats[:abuse             ][:percentage]} ,
      other:             { cases: stats[:other             ][:cases] , percentage: stats[:other             ][:percentage]} ,
    }

    total_cases
  end

  # =========================================================================================================================================

  # Helper Methods
  # -----------------------------------------------------------------------------------------------------------
  # Used By:
    # 'Percentage of Children who received Child Protection Services'
    # 'Registered and Closed Cases by Month'
    # 'Significant Harm Cases by Protection Concern'
  # Get Cases Based on:
    # Who's the User
    # Risk Level
    # Whether the Case is Registered or Not
  #TODO Need get Records based on Graph Roles
  def self.get_childs(user, is_risk_level_high = nil, registered = nil)
    case user.role.name
    #? What does this do? What purpose does this scope have?
    when "CP Manager"
      with_province(user)
    # All Cases of a Particular Group and Paricular Risk Level
    when "CPI In-charge"
      get_cases_for_particular_user_group(user.user_groups, is_risk_level_high)
    # All Cases of a Particular User, Particular Risk Level, and Registeration Status
    when "CPO" || "Superuser"
      get_cases_assigned_to_specific_user(user, is_risk_level_high, registered).results
    # All Cases that are owned by the users under an Agency and are also owned by a particular location
    else
      get_cases_with_district_and_agency(user, is_risk_level_high)
    end
  end

  # All Cases of a Particular Group and Paricular Risk Level
  def self.get_cases_for_particular_user_group(user_groups, is_risk_level_high = nil)
    # Returns Usernames that Own the Usergroups
    usernames = user_groups.first.users.pluck(:user_name)

    #TODO See if this can be optimized. Uses cases for cases.total and then running the same code with
    #TODO - search variable seems not right.

    # risk_level is one of the store_accessors
    # Get Cases that are owned by given Usernames
    cases = Child.search do
      with(:owned_by, usernames)
      with(:risk_level, 'high') if is_risk_level_high.present?
    end

    # Get Cases that are owned by given Usernames and Also Paginate them.
    search = Child.search do
      with(:owned_by, usernames)
      with(:risk_level, 'high') if is_risk_level_high.present?

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # All Cases of a Particular User, Paricular Risk Level, and Registeration Status
  def self.get_cases_assigned_to_specific_user(user, is_risk_level_high = nil, registered = nil)
    username = user.user_name

    #TODO See if this can be optimized. Uses cases for cases.total and then running the same code with
    #TODO - search variable seems not right.

    # risk_level is one of the store_accessors
    cases = Child.search do
      with(:owned_by, username)
      with(:risk_level, 'high') if is_risk_level_high.present?
    end

    search = Child.search do
      with(:owned_by, username)
      with(:risk_level, 'high') if is_risk_level_high.present?

      paginate :page => 1, :per_page => cases.total
    end

    search
  end

  # All Cases that are owned by the users under an Agency and are also owned by a particular location
  def self.get_cases_with_district_and_agency(user, is_risk_level_high = nil)
    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    #TODO See if this can be optimized. Uses cases for cases.total and then running the same code with
    #TODO - search variable seems not right.

    cases = Child.search do
      with(:risk_level, 'high') if is_risk_level_high.present?
      any_of do
        with(:owned_by, usernames)
        with(:owned_by_location, user.location)
      end
    end

    search = Child.search do
      with(:risk_level, 'high') if is_risk_level_high.present?
      any_of do
        with(:owned_by, usernames)
        with(:owned_by_location, user.location)
      end
      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # Used By:
    # resolved_cases_by_gender_and_types_of_violence
  # Closed Cases by Sex and Protection Concern
  #TODO Need get Records based on Graph Roles
  def self.get_resolved_cases_for_role(user, is_risk_level_high = nil)
    case user.role.name
    when "CP Manager" || "Superuser"
      get_resolved_cases_by_province_and_agency(user, is_risk_level_high)
    when "CPI In-charge" || "Superuser"
      get_resolved_cases_for_particular_user_group(user.user_groups, is_risk_level_high).results
    when "CPO" || "Superuser"
      get_resolved_cases_with_user(user.user_name, is_risk_level_high).results
    else
      get_resolved_cases_with_district_and_agency(user, is_risk_level_high)
    end
  end

  #TODO Check if all possible value for case closure need to be searched against in any_of block
  # Closed Cases by Sex and Protection Concern
  def self.get_resolved_cases_by_province_and_agency(user, is_risk_level_high = nil)
    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)
    # User's Province
    province = with_province(user)

    # Get Cases that are Closed and have are of High Risk Level
    search = Child.search do
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?

      # Gets any record that matches either condition
      any_of do
        with(:owned_by, usernames)
        with(:owned_by_location, province)
      end

      #? Do I even need this ? I am getting all cases that are closed regardless
      # Gets any record that matches either condition
      any_of do
        with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_all_met_811860" })
        with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_substantially_met_and_there_is_no_child_protection_concern_b0f5a44" })
      end
    end

    search.results
  end

  #TODO Check if all possible value for case closure need to be searched against in any_of block
  # Closed Cases by Sex and Protection Concern
  def self.get_resolved_cases_for_particular_user_group(user_groups, is_risk_level_high = nil)
    usernames = user_groups.first.users.pluck(:user_name)
    search = Child.search do
      with(:owned_by, usernames)
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?


      any_of do
        with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_all_met_811860" })
        with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_substantially_met_and_there_is_no_child_protection_concern_b0f5a44" })
      end
    end

    search
  end

  #TODO Check if all possible value for case closure need to be searched against in any_of block
  # Closed Cases by Sex and Protection Concern
  def self.get_resolved_cases_with_user(username , is_risk_level_high = nil)
    cases = Child.search do
      with(:owned_by, username)
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?
    end

    search = Child.search do
      with(:owned_by, username)
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?

      paginate :page => 1, :per_page => cases.total
    end

    search
  end

  #TODO Check if all possible value for case closure need to be searched against in any_of block
  # Closed Cases by Sex and Protection Concern
  def self.get_resolved_cases_with_district_and_agency(user, is_risk_level_high = nil)
    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    cases = Child.search do
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:owned_by, usernames)
        with(:owned_by_location, user.location)
      end

      any_of do
        with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => 'case_goals_all_met_811860' })
        with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_substantially_met_and_there_is_no_child_protection_concern_b0f5a44" })
      end
    end

    search = Child.search do
      with(:status, "closed")
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:owned_by, usernames)
        with(:owned_by_location, user.location)
      end

      any_of do
        with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_all_met_811860" })
        with(:data, { 'what_is_the_reason_for_closing_this_case__d2d2ce8' => "case_goals_substantially_met_and_there_is_no_child_protection_concern_b0f5a44" })
      end

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # 'Cases Referral (To Agency )'
  #TODO Logic needs to be modified, There is no Agency Field Under referal Form, Ask for that.
  def self.get_reffered_cases
    search = Child.search do
      without(:assigned_user_names, nil)
    end

    search.results
  end

  # TODO Seem quite simple, May need to modfy this.
  #  Registered and Closed Cases by Month
  def self.hash_return_for_month_wise_api
    month_list = {
      "Jan" => get_gender_hash,
      "Feb" => get_gender_hash,
      "Mar" => get_gender_hash,
      "Apr" => get_gender_hash,
      "May" => get_gender_hash,
      "Jun" => get_gender_hash,
      "Jul" => get_gender_hash,
      "Aug" => get_gender_hash,
      "Sep" => get_gender_hash,
      "Oct" => get_gender_hash,
      "Nov" => get_gender_hash,
      "Dec" => get_gender_hash,
    }

    month_list
  end

  # TODO Seem quite simple, May need to modfy this.
  #  Registered and Closed Cases by Month
  def self.get_gender_hash
    gender_list = {
      "male" => 0,
      "female" => 0,
      "transgender" => 0,
      "total" => 0
    }

    gender_list
  end

  def self.get_percentage(value, count)
    ((value / count.to_f) * 100).round
  end
  # -----------------------------------------------------------------------------------------------------------
end

# rubocop:enable Metrics/ClassLength
