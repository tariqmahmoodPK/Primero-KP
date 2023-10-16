# NOTE All the methods that return the statistics for each of the Graphs
module Graphs
  # NOTE Here are the different types of Protection Concerns tracked:
    # 1) violence:
      # Cases related to Violence.
      # Display Text: 'Violence'
      # Lookup Value/Id: other

    # 2) exploitation:
      # Cases related to Exploitation.
      # Display Text: 'Exploitation'
      # Lookup Value/Id: exploitation_b9352d1

    # 3) neglect:
      # Cases related to Neglect.
      # Display Text: 'Neglect'
      # Lookup Value/Id: neglect_a7b48b2

    # 4) harmful_practices:
      # Cases related to Harmful practices.
      # Display Text: 'Harmful practice(s)'
      # Lookup Value/Id: harmful_practice_s__d1f7955

    # 5) abuse:
      # Cases related to Abuse.
      # Display Text: 'Abuse'
      # Lookup Value/Id: other_b637c39

    # 6) other:
      # Cases that don't fit into the specific categories mentioned above.
      # Display Text: 'Other'
      # Lookup Value/Id: other_7b13407
  # NOTE End --------------------------------------------------------------------------------

  # NOTE Methods corresponding to each Graph

  # 'Percentage of Children who received Child Protection Services'
  def percentage_children_received_child_protection_services_stats(user)
    # Stats Calculation Formula:
      # (< No. of Cases by Protection Concern > / < Total Number of Cases by Protection Concern >) and has the Service provided

    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'Social Case Worker'    ,
      'Psychologist'          ,
      'Child Helpline Officer',
      'Referral'              ,
      'CPO'                   ,
      'CPWC'
    ]

    # The 'stats' data structure stores statistics for different types of Protection Concerns.
      # Each Protection Concern is represented as a key-value pair, where:
      # 'cases' indicates the number of cases associated with that concern.
      # 'percentage' represents the percentage of cases compared to the total cases that have any of these Protection Concerns

    stats = {
      violence:          { cases: 0 , percentage: 0 },
      exploitation:      { cases: 0 , percentage: 0 },
      neglect:           { cases: 0 , percentage: 0 },
      harmful_practices: { cases: 0 , percentage: 0 },
      abuse:             { cases: 0 , percentage: 0 },
      other:             { cases: 0 , percentage: 0 },
    }

    # Getting Total Number of Cases that are High Risk
    high_risk_cases = Child.get_childern_records(user, "high")
    total_case_count = high_risk_cases.count

    # Calculate Stats
    high_risk_cases.each do |child|
      # child.data["response_on_referred_case_da89310"] is an array containing a hash
      response_on_referred_case = child.data["response_on_referred_case_da89310"]

      # has_the_service_been_provided__23eb99e returns a string that is either "true" or "false"
      if response_on_referred_case.present? && response_on_referred_case[0]["has_the_service_been_provided__23eb99e"] == "true"
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
    end

    # Get Percentages
    stats.each do |key, value|
      value[:percentage] = get_percentage(value[:cases], total_case_count) unless total_case_count.eql?(0)
    end

    # Final Stats
    total_cases =  {
      violence: {
        cases:      stats[:violence][:cases],
        percentage: stats[:violence][:percentage]
      },
      exploitation: {
        cases:      stats[:exploitation][:cases],
        percentage: stats[:exploitation][:percentage]
      },
      neglect: {
        cases:      stats[:neglect][:cases],
        percentage: stats[:neglect][:percentage]
      },
      harmful_practices: {
        cases:      stats[:harmful_practices ][:cases],
        percentage: stats[:harmful_practices ][:percentage]
      },
      abuse: {
        cases:      stats[:abuse][:cases],
        percentage: stats[:abuse][:percentage]
      },
      other: {
        cases:      stats[:other][:cases],
        percentage: stats[:other][:percentage]
      },
    }

    total_cases
  end

  # 'Closed Cases by Sex and Reason'
  def resolved_cases_by_gender_and_reason_stats(user)
    # Stats Calculation Formula:
      # Total Number of Closed Cases by Sex
        # Where the 'What is reason for closing this case' contains these dropdown values: (Each Reason is a Separate bar).
          # * 1) 'Case goals all met'
            # case_goals_all_met_811860
          # *  2) 'Case goals substantially met and there is no further child protection concern'
            # case_goals_substantially_met_and_there_is_no_further_child_protection_concern_376876
          # *  3) 'Child reached adulthood'
            # child_reached_adulthood_490887
          # *  4) 'Child refuses services'
            # child_refuses_services_181533
          # *  5) 'Safety of child'
            # safety_of_child_362513
          # *  6) 'Death of child'
            # death_of_child_285462
          # *  7) 'Other'
            # other_100182

    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'Social Case Worker'    ,
      'Psychologist'          ,
      'Child Helpline Officer',
      'Referral'              ,
      'CPO'                   ,
      'CPWC'
    ]

    # Statistics related to different case scenarios.
      # Each key represents a specific case scenario, and the corresponding value is a nested hash
        # that keeps track of counts for different genders (male, female, transgender).
      # The number of Male, Female, and Transgender counts make up the total number of cases that
        # have one of the 'What is reason for closing this case' options.
    stats = {
      case_goals_all_met:           { male: 0, female: 0, transgender: 0 }, # case_goals_all_met_811860
      case_goals_substantially_met: { male: 0, female: 0, transgender: 0 }, # case_goals_substantially_met_and_there_is_no_further_child_protection_concern_376876
      child_reached_adulthood:      { male: 0, female: 0, transgender: 0 }, # child_reached_adulthood_490887
      child_refuses_services:       { male: 0, female: 0, transgender: 0 }, # child_refuses_services_181533
      safety_of_child:              { male: 0, female: 0, transgender: 0 }, # safety_of_child_362513
      death_of_child:               { male: 0, female: 0, transgender: 0 }, # death_of_child_285462
      other:                        { male: 0, female: 0, transgender: 0 }, # other_100182
    }

    get_resolved_cases_for_role(user, "high").each do |child|
      # Getting 'transgender_a797d7e' for child.data["sex"].
      # That exactly match with the 'transgender' word.
      # So, using this line.
      gender = (child.data["sex"].in? ["male", "female"]) ? child.data["sex"] : "transgender"
      next unless gender

      if child.data["case_goals_all_met_811860"].present?
        stats[:case_goals_all_met][gender.to_sym] += 1
      end

      if child.data["case_goals_substantially_met_and_there_is_no_further_child_protection_concern_376876"].present?
        stats[:case_goals_substantially_met][gender.to_sym] += 1
      end

      if child.data["child_reached_adulthood_490887"].present?
        stats[:child_reached_adulthood][gender.to_sym] += 1
      end

      if child.data["child_refuses_services_181533"].present?
        stats[:child_refuses_services][gender.to_sym] += 1
      end

      if child.data["safety_of_child_362513"].present?
        stats[:safety_of_child][gender.to_sym] += 1
      end

      if child.data["death_of_child_285462"].present?
        stats[:death_of_child][gender.to_sym] += 1
      end

      if child.data["other_100182"].present?
        stats[:other][gender.to_sym] += 1
      end
    end

    # NOTE Needed to do it for properly get the 'Display Text' Values of these records, To Display on the Graph
    formatted_stats = {
      case_goals_all_met_811860:      stats[:case_goals_all_met],
      case_goals_substantially_met_and_there_is_no_further_child_protection_concern_376876: stats[:case_goals_substantially_met],
      child_reached_adulthood_490887: stats[:child_reached_adulthood],
      child_refuses_services_181533:  stats[:child_refuses_services],
      safety_of_child_362513:         stats[:safety_of_child],
      death_of_child_285462:          stats[:death_of_child],
      other_100182:                   stats[:other]
    }

    formatted_stats
  end

  # 'Cases requiring Alternative Care Placement Services'
  def alternative_care_placement_by_gender(user)
    # Stats Calculation Formula:
      # Total Number of Open Cases Where Nationality is 'Pakistani' or 'Afghani' or 'Irani'
      # Desegregated by Sex

    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'Social Case Worker'    ,
      'Psychologist'          ,
      'Child Helpline Officer',
      'Referral'              ,
      'CPO'                   ,
      'CPWC'
    ]

    # Each key represents a specific country, and the corresponding value is a nested hash
      # that keeps track of counts for different genders (male, female, transgender).
    # The number of Male, Female, and Transgender counts make up the total number of cases that
      # have one of the 'Nationality' options.

    stats = {
      pakistani: { male: 0, female: 0, transgender: 0 }, # Lookup id: nationality1
      afgani:    { male: 0, female: 0, transgender: 0 }, # Lookup id: nationality2
      irani:     { male: 0, female: 0, transgender: 0 }, # Lookup id: nationality3
      other:     { male: 0, female: 0, transgender: 0 }, # Lookup id: nationality10
    }

    cases_requiring_alternative_care = get_cases_requiring_alternative_care(user)

    cases_requiring_alternative_care.each do |child|
      # Getting 'transgender_a797d7e' for child.data["sex"].
      # That exactly match with the 'transgender' word.
      # So, using this line.
      gender = (child.data["sex"].in? ["male", "female"]) ? child.data["sex"] : "transgender"
      next unless gender

      if child.data["nationality_b80911e"].include?("nationality1")
        stats[:pakistani][gender.to_sym] += 1
      end

      if child.data["nationality_b80911e"].include?("nationality2")
        stats[:afgani][gender.to_sym] += 1
      end

      if child.data["nationality_b80911e"].include?("nationality3")
        stats[:irani][gender.to_sym] += 1
      end

      if child.data["nationality_b80911e"].include?("nationality10")
        stats[:other][gender.to_sym] += 1
      end
    end

    # NOTE Needed to do it for properly get the 'Display Text' Values of these records, To Display on the Graph
    formatted_stats = {
      nationality1:  stats[:pakistani],
      nationality2:  stats[:afgani],
      nationality3:  stats[:irani],
      nationality10: stats[:other]
    }

    formatted_stats
  end

  # 'Cases Referrals (To Agency)'
  def cases_referrals_to_agency_stats(user)
    # Stats Calculation Formula:
      # Total Number of Open Referrals cases Where Referred to Agency, Desegregated by Sex

    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'Social Case Worker'    ,
      'Psychologist'          ,
      'Child Helpline Officer',
      'Referral'              ,
      'CPO'                   ,
      'CPWC'
    ]

    # Initialize the stats hash for all agencies
    stats = {}

    Agency.all.each do |agency|
      stats[agency.name] = { male: 0, female: 0, transgender: 0 }
    end

    # Get cases referred to agencies for the user
    cases_referred_to_agencies = get_cases_referred_to_agencies(user, nil, true)

    cases_referred_to_agencies.each do |child|
      # Getting 'transgender_a797d7e' for child.data["sex"].
      # That exactly match with the 'transgender' word.
      # So, using this line.
      gender = (child.data["sex"].in? ["male", "female"]) ? child.data["sex"] : "transgender"

      agencies_assigned = child.data["assigned_user_names"].map do |refer|
        user = User.find_by(user_name: refer)
        user.agency_id ? Agency.find(user.agency_id) : nil
      end.compact

      agency_name = agencies_assigned[0].name

      next unless gender && agency_name

      # Increment the count for the respective gender within the agency's statistics
      stats[agency_name][gender.to_sym] += 1
    end

    stats
  end

  # 'Registered and Closed Cases by Month'
  def month_wise_registered_and_resolved_cases(user)
    # Stats Calculation Formula:
      # Total Number of Registered and Closed Cases Gender wise (by User) – Last 12 months

    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'Social Case Worker'    ,
      'Psychologist'          ,
      'Child Helpline Officer',
      'Referral'              ,
      'CPO'                   ,
      'CPWC'
    ]

    stats = {
      "Resolved"   => hash_return_for_month_wise_api, # Closed
      "Registered" => hash_return_for_month_wise_api  # Registered
    }

    Child.get_childern_records(user).each do |child|
      day = child.created_at
      next unless day.to_date.in? (Date.today.prev_year..Date.today)

      key = day.strftime("%B")[0,3]
      # Getting 'transgender_a797d7e' for child.data["sex"].
      # That exactly match with the 'transgender' word.
      # So, using this line.
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

  # 'High Risk Cases by Protection Concern'
  def high_risk_cases_by_protection_concern_stats(user)
    # Stats Calculation Formula:
      # Total No of Open Cases by Protection Concern Where the Risk Level = High

    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'Social Case Worker'    ,
      'Psychologist'          ,
      'Child Helpline Officer',
      'Referral'              ,
      'CPO'                   ,
      'CPWC'
    ]

    # The 'stats' data structure stores statistics for different types of Protection Concerns.
      # Each Protection Concern is represented as a key-value pair, where:
      # 'cases' indicates the number of cases associated with that concern.
      # 'percentage' represents the percentage of cases compared to the total cases that have any of these Protection Concerns

    stats = {
      violence:          { cases: 0 , percentage: 0 },
      exploitation:      { cases: 0 , percentage: 0 },
      neglect:           { cases: 0 , percentage: 0 },
      harmful_practices: { cases: 0 , percentage: 0 },
      abuse:             { cases: 0 , percentage: 0 },
      other:             { cases: 0 , percentage: 0 },
    }

    # Getting Total Number of Opened Cases that are High Risk
    high_risk_cases = Child.get_childern_records(user, "high", true)
    total_case_count = high_risk_cases.count

    # Calculate Stats
    high_risk_cases.each do |child|
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

    # Get Percentages
    stats.each do |key, value|
      value[:percentage] = get_percentage(value[:cases], total_case_count) unless total_case_count.eql?(0)
    end

    # NOTE Needed to do it for properly get the 'Display Text' Values of these records, To Display on the Graph
    total_cases =  {
      other:                       { cases: stats[:violence          ][:cases] , percentage: stats[:violence          ][:percentage]} ,
      exploitation_b9352d1:        { cases: stats[:exploitation      ][:cases] , percentage: stats[:exploitation      ][:percentage]} ,
      neglect_a7b48b2:             { cases: stats[:neglect           ][:cases] , percentage: stats[:neglect           ][:percentage]} ,
      harmful_practice_s__d1f7955: { cases: stats[:harmful_practices ][:cases] , percentage: stats[:harmful_practices ][:percentage]} ,
      other_b637c39:               { cases: stats[:abuse             ][:cases] , percentage: stats[:abuse             ][:percentage]} ,
      other_7b13407:               { cases: stats[:other             ][:cases] , percentage: stats[:other             ][:percentage]} ,
    }

    total_cases
  end

  # 'Registered Cases by Protection Concern'
  def registered_cases_by_protection_concern_stats(user)
    # Stats Calculation Formula:
      # Total No of Open Cases by Protection Concern desegregated by Sex (by User)

    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'Social Case Worker'    ,
      'Psychologist'          ,
      'Child Helpline Officer',
      'Referral'              ,
      'CPO'                   ,
      'CPWC'
    ]

    # The 'stats' data structure stores statistics for different types of Protection Concerns.
      # Each Protection Concern is represented as a key-value pair, where:
      # 'cases' indicates the number of cases associated with that concern.
      # 'percentage' represents the percentage of cases compared to the total cases that have any of these Protection Concerns

    stats = {
      violence:          { male: 0, female: 0, transgender: 0 },
      exploitation:      { male: 0, female: 0, transgender: 0 },
      neglect:           { male: 0, female: 0, transgender: 0 },
      harmful_practices: { male: 0, female: 0, transgender: 0 },
      abuse:             { male: 0, female: 0, transgender: 0 },
      other:             { male: 0, female: 0, transgender: 0 },
    }

    # Calculate Stats
    Child.get_childern_records(user, "high", true).each do |child|
      # child.data["protection_concerns"] returns an array of strings, Each specifing a Protection Concern

      # Getting 'transgender_a797d7e' for child.data["sex"].
      # That exactly match with the 'transgender' word.
      # So, using this line.
      gender = (child.data["sex"].in? ["male", "female"]) ? child.data["sex"] : "transgender"
      next unless gender

      if child.data["protection_concerns"].include?("other")
        stats[:violence][gender.to_sym] += 1
      end

      if child.data["protection_concerns"].include?("exploitation_b9352d1")
        stats[:exploitation][gender.to_sym] += 1
      end

      if child.data["protection_concerns"].include?("neglect_a7b48b2")
        stats[:neglect][gender.to_sym] += 1
      end

      if child.data["protection_concerns"].include?("harmful_practice_s__d1f7955")
        stats[:harmful_practices][gender.to_sym] += 1
      end

      if child.data["protection_concerns"].include?("other_b637c39")
        stats[:abuse][gender.to_sym] += 1
      end

      if child.data["protection_concerns"].include?("other_b637c39")
        stats[:other][gender.to_sym] += 1
      end
    end

    # NOTE Needed to do it for properly get the 'Display Text' Values of these records, To Display on the Graph
    formatted_stats = {
      other:                        stats[:violence],
      exploitation_b9352d1:         stats[:exploitation],
      neglect_a7b48b2:              stats[:neglect],
      harmful_practice_s__d1f7955:  stats[:harmful_practices],
      other_b637c39:                stats[:abuse],
      other_b637c39:                stats[:other],
    }

    formatted_stats
  end
end
