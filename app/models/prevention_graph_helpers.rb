# NOTE Helper Methods for Graphs
module PreventionGraphHelpers
  # Used By:
    # 'Community based Child Protection Committees'
  #
  def get_male_community_based_child_protection_committees_records
    Prevention.where("data -> 'male_community_based_child_protection_committees' IS NOT NULL")
  end

  # Used By:
    # 'Community based Child Protection Committees'
  #
  def get_female_community_based_child_protection_committees_records
    Prevention.where("data -> 'female_community_based_child_protection_committees' IS NOT NULL")
  end

  # Used By:
    # 'Community Engagement Sessions'
  #
  def get_community_engagement_sessions_records
    Prevention.where("data -> 'community_engagement_sessions' IS NOT NULL")
  end
end
