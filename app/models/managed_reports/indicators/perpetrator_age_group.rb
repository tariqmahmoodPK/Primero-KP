# frozen_string_literal: true

# An indicator that returns the total of incidents grouped by the perpetrator_age_group
class ManagedReports::Indicators::PerpetratorAgeGroup < ManagedReports::SqlReportIndicator
  class << self
    def id
      'perpetrator_age_group'
    end

    # rubocop:disable Metrics/MethodLength
    def sql(current_user, params = {})
      date_param = filter_date(params)
      %{
        select
          alleged_perpetrator.age_group as id,
          #{grouped_date_query(params['grouped_by'], date_param)&.concat(' as group_id,')}
          count(*) as total
        from
        incidents,
        jsonb_to_recordset(data #> '{alleged_perpetrator}') as alleged_perpetrator(
          age_group text,
          unique_id text,
          primary_perpetrator text,
          perpetrator_sex text,
          former_perpetrator boolean,
          perpetrator_ethnicity text,
          perpetrator_occupation text,
          perpetrator_nationality text,
          perpetrator_relationship text
        )
        where data ->> 'alleged_perpetrator' is not null
        and alleged_perpetrator.primary_perpetrator =  'primary'
        #{date_range_query(date_param)&.prepend('and ')}
        #{equal_value_query(params['module_id'])&.prepend('and ')}
        #{user_scope_query(current_user)&.prepend('and ')}
        group by alleged_perpetrator.age_group
        #{grouped_date_query(params['grouped_by'], date_param)&.prepend(', ')}
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
