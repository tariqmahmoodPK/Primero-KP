# frozen_string_literal: true

# Describes Recruitment subreport in Primero.
class ManagedReports::SubReports::Recruitment < ManagedReports::SubReport
  def id
    'recruitment'
  end

  def indicators
    [
      ManagedReports::Indicators::ViolationTally,
      ManagedReports::Indicators::Perpetrators,
      ManagedReports::Indicators::ReportingLocation,
      ManagedReports::Indicators::TypeOfUse,
      ManagedReports::Indicators::FactorsOfRecruitment
    ]
  end

  def lookups
    {
      ManagedReports::Indicators::Perpetrators.id => 'lookup-armed-force-group-or-other-party',
      ManagedReports::Indicators::ReportingLocation.id => 'Location',
      ManagedReports::Indicators::TypeOfUse.id => 'lookup-combat-role-type',
      ManagedReports::Indicators::FactorsOfRecruitment.id => 'lookup-recruitment-factors',
      ManagedReports::Indicators::ViolationTally.id => 'lookup-violation-tally-options'
    }
  end

  def build_report(current_user, params = {})
    super(current_user, params.merge('type' => SearchFilters::Value.new(field_name: 'type', value: id)))
  end

  def indicators_subcolumns
    sub_column_items = sub_column_items(lookups[ManagedReports::Indicators::ViolationTally.id])

    {
      ManagedReports::Indicators::Perpetrators.id => sub_column_items,
      ManagedReports::Indicators::ReportingLocation.id => sub_column_items,
      ManagedReports::Indicators::TypeOfUse.id => sub_column_items,
      ManagedReports::Indicators::FactorsOfRecruitment.id => sub_column_items
    }
  end
end
