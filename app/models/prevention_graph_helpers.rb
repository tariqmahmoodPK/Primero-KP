# NOTE Helper Methods for Graphs
module PreventionGraphHelpers
  # Used By:
    # 'Community based Child Protection Committees'
    # 'Community Engagement Sessions'
  #
  # TODO Modify it to fit the Prevention Graphs Needs
  def get_records(user)
    # User's role
    role = user.role.name

    # Getting records based on the Permissions of Each Role to View the Graphs
    case role
    # View Cases of a User
    when 'Social Case Worker', 'Psychologist', 'Child Helpline Officer'
      # get_cases_assigned_to_specific_user(user)
    # View Cases of all Districts (Provincial data)
    when 'CPWC'
      # get_cases_assigned_to_specific_location(user)
    # View Cases of
      # Users with Roles:
        # Social Case Worker
        # Psychologist
        # Child Helpline Operator
      # That are Working in his UserGroup.
    when 'CPO'
      # get_cases_for_particular_user_group(user)
    # View Cases Referred to User
    when 'Referral'
      # get_cases_referred_to_user(user)
    else
      # All Cases that are owned by the users under an Agency and are also owned by a particular location
      # get_cases_with_location_and_agency(user)
    end
  end
end
