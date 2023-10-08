# NOTE Helper Methods for Graphs
module GraphHelpers
  # Used By:
    # 'Percentage of Children who received Child Protection Services'
    # 'Registered and Closed Cases by Month'
    # 'Significant Harm Cases by Protection Concern'
  def get_childs(user, is_risk_level_high = nil)
    # User's role
    role = user.role.name

    # Getting records based on the Permissions of Each Role to View the Graphs
    case role
    # View Cases of a User
    when 'Social Case Worker', 'Psychologist', 'Child Helpline Officer'
      get_cases_assigned_to_specific_user(user, is_risk_level_high)
    # View Cases of all Districts (Provincial data)
    when 'CPWC'
      get_cases_assigned_to_specific_location(user, is_risk_level_high)
    # View Cases of
      # User with Roles:
        # Social Case Worker
        # Psychologist
        # Child Helpline Operator
      # That are Working in his UserGroup.
    when 'CPO'
      get_cases_for_particular_user_group(user, is_risk_level_high)
    # View Cases Referred to User
    when 'Referral'
      get_cases_referred_to_user(user, is_risk_level_high)
    else
      #TODO Ask what should be here
      # Temporarily using this method that was used in the Sindh Version as well.
      get_cases_with_district_and_agency(user, is_risk_level_high)
    end
  end

  # -------------------------------------------------------------------------------------------------

  # View Cases of a User
  def get_cases_assigned_to_specific_user(user, is_risk_level_high = nil)
    username = user.user_name

    # Search for Records that are 'Owned By'/'Created by' Username
    # And have a 'High Risk Level'/'Significant Harm'
    cases = Child.search do
      with(:owned_by, username)
      with(:risk_level, 'high') if is_risk_level_high.present?
    end

    # Needed to panginate using the Total Number of Cases. That is why , Had to search twice.
    search = Child.search do
      with(:owned_by, username)
      with(:risk_level, 'high') if is_risk_level_high.present?

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  # View Cases of all Districts (Provincial data)
  # TODO Modify the Logic for it if necessary after Clearing out Questions and Assumptions
  def get_cases_assigned_to_specific_location(user, is_risk_level_high = nil)
    # User's Location Code
    location_code = user.location

    cases = nil
    search = nil

    # If the location of the each record matches the User's Location then get those records
    if location_code.present?
      cases = Child.search do
        with(:location_current, location_code)
        with(:risk_level, 'high') if is_risk_level_high.present?
      end

      search = Child.search do
        with(:location_current, location_code)
        with(:risk_level, 'high') if is_risk_level_high.present?

        paginate :page => 1, :per_page => cases.total
      end
    # If there is no User location present then get all the records with location in 'Khyber Pakhtunkhwa'/KPK
    else
      cases = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:risk_level, 'high') if is_risk_level_high.present?
      end

      search = Child.search do
        with_province # Checks if the location_current has 'KPK' in it
        with(:risk_level, 'high') if is_risk_level_high.present?

        paginate :page => 1, :per_page => cases.total
      end
    end

    search.results
  end

  # View Cases of Social Case Worker, Psychologist, Child Helpline Operator, Working in his user group.
  def get_cases_for_particular_user_group(cpo_user, is_risk_level_high = nil)
    # Find users with the specified roles ('Social Case Worker', 'Psychologist', 'Child Helpline Officer')
    role_names = [
      'Social Case Worker',
      'Psychologist',
      'Child Helpline Officer'
    ]

    users_with_roles = User.joins(:role).where(roles: { name: role_names })

    # Find the user group of the cpo user
    cpo_user_group_ids = cpo_user.user_groups.pluck(:id)

    # Find users with the specified roles who are in the same user group as the cpo user
    users_in_same_user_group = users_with_roles.joins(:user_groups).where(user_groups: { id: cpo_user_group_ids })

    # Extract the usernames of users in the same user group
    usernames = users_in_same_user_group.pluck(:user_name)

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

  # View Cases Referred to User
  def get_cases_referred_to_user(user, is_risk_level_high = nil)
    # User's Name, Duh!
    user_name = user.name

    results = []

    # Get all the referred cases and see if the User has any cases referred to him.
    Child.get_referred_cases.each do |child|
      if is_risk_level_high.present? && child.risk_level == 'high'
        child.data["assigned_user_names"].each do |refered_user|
          # If referred_user matches the user_name, add the child to results
          results << child if refered_user == user_name
        end
      end
    end

    results
  end

  # Get all Child records where 'assigned_user_names' in not nil
  def get_referred_cases
    search = Child.search do
      without(:assigned_user_names, nil)
    end

    search.results
  end

  # All Cases that are owned by the users under an Agency and are also owned by a particular location
  def get_cases_with_district_and_agency(user, is_risk_level_high = nil)
    # User's Location Code
    location_code = user.location

    # Users under an Agency that another User created.
    usernames = user.agency.users.pluck(:user_name)

    # Search for Records
      # That have a 'High Risk Level'/'Significant Harm' and
      # That are either 'Owned By'/'Created by' Username or have the same location as the User.
    cases = Child.search do
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:owned_by, usernames)
        with(:location_current, location_code)
        # TODO Remove this after
        # This won't wont as there in no longer an attribute 'owned_by_location'
        # with(:owned_by_location, user.location)
      end
    end

    # Needed to panginate using the Total Number of Cases. That is why , Had to search twice.
    search = Child.search do
      with(:risk_level, 'high') if is_risk_level_high.present?

      any_of do
        with(:owned_by, usernames)
        with(:location_current, location_code)
        # TODO Remove this after
        # with(:owned_by_location, user.location)
      end

      paginate :page => 1, :per_page => cases.total
    end

    search.results
  end

  def get_percentage(value, count)
    ((value / count.to_f) * 100).round
  end
end
