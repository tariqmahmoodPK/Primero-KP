# frozen_string_literal: true

require 'rails_helper'

describe ManagedReports::Indicators::AttackType do
  before do
    clean_data(Incident, Violation, UserGroup, User, Agency, Role)

    permissions = [
      Permission.new(
        resource: Permission::MANAGED_REPORT,
        actions: [
          Permission::VIOLATION_REPORT
        ]
      )
    ]
    self_role = Role.create!(
      name: 'Self Role 1',
      unique_id: 'self-role-1',
      group_permission: Permission::SELF,
      permissions: permissions
    )

    group_role = Role.create!(
      name: 'Group Role 1',
      unique_id: 'group-role-1',
      group_permission: Permission::GROUP,
      permissions: permissions
    )

    agency_role = Role.create!(
      name: 'Agency Role 1',
      unique_id: 'agency-role-1',
      group_permission: Permission::AGENCY,
      permissions: permissions
    )

    all_role = Role.create!(
      name: 'All Role 1',
      unique_id: 'all-role-1',
      group_permission: Permission::ALL,
      permissions: permissions
    )

    agency_a = Agency.create!(name: 'Agency 1', agency_code: 'agency1', unique_id: 'agency1')
    agency_b = Agency.create!(name: 'Agency 2', agency_code: 'agency2', unique_id: 'agency2')

    group_a = UserGroup.create(unique_id: 'group-a', name: 'Group A')
    group_b = UserGroup.create(unique_id: 'group-b', name: 'Group B')

    @self_user = User.create!(
      full_name: 'Self User',
      user_name: 'self_user',
      email: 'self_user@localhost.com',
      agency_id: agency_a.id,
      user_groups: [group_a],
      role: self_role
    )

    @group_user = User.create!(
      full_name: 'Group User',
      user_name: 'group_user',
      email: 'group_user@localhost.com',
      agency_id: agency_b.id,
      user_groups: [group_b],
      role: group_role
    )

    @agency_user = User.create!(
      full_name: 'Agency User',
      user_name: 'agency_user',
      email: 'agency_user@localhost.com',
      agency_id: agency_b.id,
      user_groups: [group_b],
      role: agency_role
    )

    @all_user = User.create!(
      full_name: 'all User',
      user_name: 'all_user',
      email: 'all_user@localhost.com',
      agency_id: agency_a.id,
      user_groups: [group_a, group_b],
      role: all_role
    )

    incident1 = Incident.new_with_user(@self_user, { incident_date: Date.new(2020, 8, 8), status: 'open' })
    incident1.save!
    incident2 = Incident.new_with_user(@group_user, { incident_date: Date.new(2021, 8, 8), status: 'open' })
    incident2.save!
    incident3 = Incident.new_with_user(@agency_user, { incident_date: Date.new(2022, 1, 8), status: 'open' })
    incident3.save!
    incident4 = Incident.new_with_user(@all_user, { incident_date: Date.new(2022, 2, 18), status: 'open' })
    incident4.save!
    incident5 = Incident.new_with_user(@all_user, { incident_date: Date.new(2022, 3, 28), status: 'open' })
    incident5.save!

    Violation.create!(
      data: {
        type: 'killing',
        attack_type: 'aerial_attack',
        violation_tally: { 'boys': 1, 'girls': 1, 'unknown': 1, 'total': 3 }
      },
      incident_id: incident1.id
    )
    Violation.create!(
      data: {
        type: 'maiming', attack_type: 'aerial_attack',
        violation_tally: { 'boys': 3, 'girls': 2, 'unknown': 1, 'total': 6 }
      },
      incident_id: incident1.id
    )
    Violation.create!(
      data: {
        type: 'killing', attack_type: 'arson', violation_tally: { 'boys': 1, 'girls': 1, 'unknown': 1, 'total': 3 }
      },
      incident_id: incident3.id
    )
    Violation.create!(
      data: {
        type: 'killing', attack_type: 'arson', violation_tally: { 'boys': 1, 'girls': 1, 'unknown': 0, 'total': 2 }
      },
      incident_id: incident4.id
    )
    Violation.create!(
      data: {
        attack_type: 'other', violation_tally: { 'boys': 5, 'girls': 10, 'unknown': 5, 'total': 20 }
      },
      incident_id: incident1.id
    )
    Violation.create!(
      data: {
        type: 'killing', attack_type: 'other', violation_tally: { 'boys': 5, 'girls': 10, 'unknown': 5, 'total': 20 }
      },
      incident_id: incident2.id
    )
    Violation.create!(
      data: {
        type: 'killing',
        attack_type: 'aerial_attack',
        violation_tally: { 'boys': 2, 'girls': 1, 'unknown': 0, 'total': 3 }
      },
      incident_id: incident5.id
    )
  end

  it 'returns data for attack type indicator' do
    attack_type_data = ManagedReports::Indicators::AttackType.build(
      nil,
      { 'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing') }
    ).data

    expect(attack_type_data).to match_array(
      [
        { boys: 3, girls: 2, id: 'aerial_attack', total: 6, unknown: 1 },
        { boys: 2, girls: 2, id: 'arson', total: 5, unknown: 1 },
        { boys: 5, girls: 10, id: 'other', unknown: 5, total: 20 }
      ]
    )
  end

  describe 'records in scope' do
    it 'returns owned records for a self scope' do
      attack_type_data = ManagedReports::Indicators::AttackType.build(
        @self_user,
        { 'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing') }
      ).data

      expect(attack_type_data).to match_array(
        [{ boys: 1, girls: 1, id: 'aerial_attack', total: 3, unknown: 1 }]
      )
    end

    it 'returns group records for a group scope' do
      attack_type_data = ManagedReports::Indicators::AttackType.build(
        @group_user,
        { 'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing') }
      ).data

      expect(attack_type_data).to match_array(
        [
          { boys: 2, girls: 1, id: 'aerial_attack', total: 3, unknown: 0 },
          { boys: 2, girls: 2, id: 'arson', total: 5, unknown: 1 },
          { boys: 5, girls: 10, id: 'other', total: 20, unknown: 5 }
        ]
      )
    end

    it 'returns agency records for an agency scope' do
      attack_type_data = ManagedReports::Indicators::AttackType.build(
        @agency_user,
        { 'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing') }
      ).data

      expect(attack_type_data).to match_array(
        [
          { boys: 5, girls: 10, id: 'other', total: 20, unknown: 5 },
          { boys: 1, girls: 1, id: 'arson', total: 3, unknown: 1 }
        ]
      )
    end

    it 'returns all records for an all scope' do
      attack_type_data = ManagedReports::Indicators::AttackType.build(
        @all_user,
        { 'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing') }
      ).data

      expect(attack_type_data).to match_array(
        [
          { boys: 3, girls: 2, id: 'aerial_attack', total: 6, unknown: 1 },
          { boys: 2, girls: 2, id: 'arson', total: 5, unknown: 1 },
          { boys: 5, girls: 10, id: 'other', unknown: 5, total: 20 }
        ]
      )
    end
  end

  describe 'grouped by' do
    context 'when is year' do
      it 'should return results grouped by year' do
        data = ManagedReports::Indicators::AttackType.build(
          nil,
          {
            'grouped_by' => SearchFilters::Value.new(field_name: 'grouped_by', value: 'year'),
            'incident_date' => SearchFilters::DateRange.new(
              field_name: 'incident_date',
              from: '2020-08-01',
              to: '2022-10-10'
            ),
            'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing')
          }
        ).data

        expect(data).to match_array(
          [
            {
              group_id: 2020,
              data: [
                { id: 'aerial_attack', total: 3, girls: 1, unknown: 1, boys: 1 }
              ]
            },
            {
              group_id: 2021,
              data: [
                { id: 'other', girls: 10, boys: 5, unknown: 5, total: 20 }
              ]
            },
            {
              group_id: 2022,
              data: [
                { id: 'aerial_attack', unknown: 0, boys: 2, girls: 1, total: 3 },
                { id: 'arson', total: 5, boys: 2, girls: 2, unknown: 1 }
              ]
            }
          ]
        )
      end
    end

    context 'when is month' do
      it 'should return results grouped by month' do
        data = ManagedReports::Indicators::AttackType.build(
          nil,
          {
            'grouped_by' => SearchFilters::Value.new(field_name: 'grouped_by', value: 'month'),
            'incident_date' => SearchFilters::DateRange.new(
              field_name: 'incident_date',
              from: '2020-08-01',
              to: '2022-04-10'
            ),
            'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing')
          }
        ).data

        expect(data).to match_array(
          [
            { group_id: '2020-08', data: [{ id: 'aerial_attack', boys: 1, girls: 1, total: 3, unknown: 1 }] },
            { group_id: '2020-09', data: [] },
            { group_id: '2020-10', data: [] },
            { group_id: '2020-11', data: [] },
            { group_id: '2020-12', data: [] },
            { group_id: '2021-01', data: [] },
            { group_id: '2021-02', data: [] },
            { group_id: '2021-03', data: [] },
            { group_id: '2021-04', data: [] },
            { group_id: '2021-05', data: [] },
            { group_id: '2021-06', data: [] },
            { group_id: '2021-07', data: [] },
            { group_id: '2021-08', data: [{ id: 'other', boys: 5, girls: 10, total: 20, unknown: 5 }] },
            { group_id: '2021-09', data: [] },
            { group_id: '2021-10', data: [] },
            { group_id: '2021-11', data: [] },
            { group_id: '2021-12', data: [] },
            { group_id: '2022-01', data: [{ id: 'arson', boys: 1, girls: 1, total: 3, unknown: 1 }] },
            { group_id: '2022-02', data: [{ id: 'arson', boys: 1, girls: 1, total: 2, unknown: 0 }] },
            { group_id: '2022-03', data: [{ id: 'aerial_attack', boys: 2, girls: 1, total: 3, unknown: 0 }] },
            { group_id: '2022-04', data: [] }
          ]
        )
      end
    end

    context 'when is quarter' do
      it 'should return results grouped by quarter' do
        data = ManagedReports::Indicators::AttackType.build(
          nil,
          {
            'grouped_by' => SearchFilters::Value.new(field_name: 'grouped_by', value: 'quarter'),
            'incident_date' => SearchFilters::DateRange.new(
              field_name: 'incident_date',
              from: '2020-08-01',
              to: '2022-03-29'
            ),
            'type' => SearchFilters::Value.new(field_name: 'type', value: 'killing')
          }
        ).data

        expect(data).to match_array(
          [
            { group_id: '2020-Q3', data: [{ id: 'aerial_attack', boys: 1, girls: 1, total: 3, unknown: 1 }] },
            { group_id: '2020-Q4', data: [] },
            { group_id: '2021-Q1', data: [] },
            { group_id: '2021-Q2', data: [] },
            { group_id: '2021-Q3', data: [{ id: 'other', boys: 5, girls: 10, total: 20, unknown: 5 }] },
            { group_id: '2021-Q4', data: [] },
            {
              group_id: '2022-Q1',
              data: [
                { id: 'aerial_attack', boys: 2, girls: 1, total: 3, unknown: 0 },
                { id: 'arson', boys: 2, girls: 2, total: 5, unknown: 1 }
              ]
            }
          ]
        )
      end
    end
  end
end
