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

    # Getting Total Number of Opened Cases that are High Risk
    high_risk_cases = Child.get_childs(user, "high")
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

end
