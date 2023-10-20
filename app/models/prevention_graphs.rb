# NOTE All the methods that return the statistics for each of the Prevention Graphs

module PreventionGraphs
  # 'Community based Child Protection Committees'
  def community_based_child_protection_committees_stats(user)
    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'CPO',
      'CP Manager',
      'Superuser'
    ]

    # Counters for calculating the number of participents for each type of paritcipant, and the total participents
    stats = {
      "Male Commitees"   => 0,
      "Female Commitees" => 0,
      "Total Commitees"  => 0
    }

    # All Community Engagement Sessions records, Records that have Prevention.data["community_engagement_sessions"].present
    male_commitees = Prevention.get_male_community_based_child_protection_committees_records
    female_commitees = Prevention.get_female_community_based_child_protection_committees_records

    stats["Male Commitees"]   = male_commitees.count
    stats["Female Commitees"] = female_commitees.count
    stats["Total Commitees"]  = stats["Male Commitees"] + stats["Female Commitees"]

    stats
  end

  # 'Community Engagement Sessions'
  def community_engagement_sessions_stats(user)
    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    return { permission: false } unless name.in? [
      'CPO',
      'CP Manager',
      'Superuser'
    ]

    # Counters for calculating the number of participents for each type of paritcipant, and the total participents
    stats = {
      num_of_boys_participants:        0,
      num_of_girl_participants:        0,
      num_of_male_participants:        0,
      num_of_female_participants:      0,
      num_of_transgender_participants: 0,
      total_num_of_participants:       0
    }

    # All Community Engagement Sessions records, Records that have Prevention.data["community_engagement_sessions"].present
    session_records = Prevention.get_community_engagement_sessions_records

    session_records.each do |session_record|
      community_engagement_sessions_info = session_record.data["community_engagement_sessions"]

      if community_engagement_sessions_info["num_of_boys_participants"].present?
        stats[:num_of_boys_participants] += 1
        stats[:total_num_of_participants] += 1
      end

      if community_engagement_sessions_info["num_of_girl_participants"].present?
        stats[:num_of_girl_participants] += 1
        stats[:total_num_of_participants] += 1
      end

      if community_engagement_sessions_info["num_of_male_participants"].present?
        stats[:num_of_male_participants] += 1
        stats[:total_num_of_participants] += 1
      end

      if community_engagement_sessions_info["num_of_female_participants"].present?
        stats[:num_of_female_participants] += 1
        stats[:total_num_of_participants] += 1
      end

      if community_engagement_sessions_info["num_of_transgender_participants"].present?
        stats[:num_of_transgender_participants] += 1
        stats[:total_num_of_participants] += 1
      end
    end

    formatted_stats = {
      "Number of Boy Participants"         => stats[:num_of_boys_participants       ],
      "Number of Girl Participants"        => stats[:num_of_girl_participants       ],
      "Number of Male Participants"        => stats[:num_of_male_participants       ],
      "Number of Female Participants"      => stats[:num_of_female_participants     ],
      "Number of Transgender Participants" => stats[:num_of_transgender_participants],
      "Total Number of Participants"       => stats[:total_num_of_participants      ],
    }

    formatted_stats
  end
end
