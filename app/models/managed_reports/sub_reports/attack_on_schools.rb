# frozen_string_literal: true

# Describes Attack on schools subreport in Primero.
class ManagedReports::SubReports::AttackOnSchools < ManagedReports::SubReport
  def id
    'attack_on_schools'
  end

  def indicators
    [
      ManagedReports::Indicators::IncidentAttackOn,
      ManagedReports::Indicators::FacilityAttackType,
      ManagedReports::Indicators::PerpetratorsDenials,
      ManagedReports::Indicators::ReportingLocationDenials
    ]
  end

  def lookups
    {
      ManagedReports::Indicators::PerpetratorsDenials.id => 'lookup-armed-force-group-or-other-party',
      ManagedReports::Indicators::ReportingLocationDenials.id => 'Location',
      ManagedReports::Indicators::FacilityAttackType.id => 'lookup-facility-attack-type'
    }
  end

  def build_report(current_user, params = {})
    super(current_user, params.merge('type' => SearchFilters::Value.new(field_name: 'type', value: id)))
  end
end
