# NOTE All the methods that return the statistics for each of the Prevention Graphs
module PreventionGraphs
  # 'Community based Child Protection Committees'
  # TODO Modify it to fit the Prevention Graphs Needs
  def community_based_child_protection_committees_stats(user)
    # TODO Ask the Formula for this Graph
    # Stats Calculation Formula:
      #

    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    # TODO Ask what are the role permisions for this Graph
    return { permission: false } unless name.in? [
      'Social Case Worker'    ,
      'Psychologist'          ,
      'Child Helpline Officer',
      'Referral'              ,
      'CPO'                   ,
      'CPWC'
    ]

    #
    stats = {

    }

    #
    records = Prevention.get_records()

    records.each do |child|
      # Calculate Stats
    end
  end

  # 'Community Engagement Sessions'
  # TODO Modify it to fit the Prevention Graphs Needs
  def community_engagement_sessions_stats(user)
    # TODO Ask the Formula for this Graph
    # Stats Calculation Formula:
      #

    # Getting User's Role to check if they are allowed to view the graph.
    name = user.role.name

    # User Roles allowed
    # TODO Ask what are the role permisions for this Graph
    return { permission: false } unless name.in? [
      'Social Case Worker'    ,
      'Psychologist'          ,
      'Child Helpline Officer',
      'Referral'              ,
      'CPO'                   ,
      'CPWC'
    ]

    #
    stats = {

    }

    #
    records = Prevention.get_records(user)

    records.each do |child|
      # Calculate Stats
    end
  end
end
