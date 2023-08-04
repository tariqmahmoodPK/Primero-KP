# frozen_string_literal: true

ORPHANS_MAP = {
  primero_modules: {
    sql: %(
        SELECT
          modules.unique_id AS unique_id,
          modules.id AS modules_id,
          programs.id AS programs_id,
          modules.primero_program_id as primero_program_id
        FROM primero_modules modules
        LEFT JOIN primero_programs programs
        ON modules.primero_program_id  = programs.id
        WHERE programs.id IS NULL AND modules.primero_program_id IS NOT NULL
    ),
    foreign_keys_map: {
      primero_program_id: 'programs_id'
    },
    primary_key: 'unique_id'
  },
  primero_modules_saved_searches: {
    sql: %(
        SELECT
          searches.id AS searches_id,
          modules.id AS modules_id,
          modules_searches.id AS id,
          modules_searches.saved_search_id AS saved_search_id,
          modules_searches.primero_module_id AS primero_module_id
        FROM primero_modules_saved_searches AS modules_searches
        LEFT JOIN saved_searches AS searches
        ON modules_searches.saved_search_id = searches.id
        LEFT JOIN primero_modules AS modules
        ON modules.id = modules_searches.primero_module_id
        WHERE (searches.id IS NULL AND modules_searches.saved_search_id IS NOT NULL)
        OR (modules.id IS NULL AND modules_searches.primero_module_id IS NOT NULL)
    ),
    foreign_keys_map: {
      saved_search_id: 'searches_id',
      primero_module_id: 'modules_id'
    },
    primary_key: 'id',
    join_table: true
  },
  primero_modules_roles: {
    sql: %(
        SELECT
          modules.id AS module_id,
          roles.id AS roles_role_id,
          modules_roles.primero_module_id,
          modules_roles.role_id
        FROM primero_modules_roles modules_roles
        LEFT join primero_modules AS modules on modules.id = modules_roles.primero_module_id
        LEFT join roles on roles.id = modules_roles.role_id
        WHERE (roles.id IS NULL AND modules_roles.role_id IS NOT NULL)
        OR (modules.id IS NULL AND modules_roles.primero_module_id IS NOT NULL)
    ),
    foreign_keys_map: {
      primero_module_id: 'module_id',
      role_id: 'roles_role_id'
    },
    join_table: true
  },
  form_sections_primero_modules: {
    sql: %(
      SELECT
        forms.id AS form_id,
        modules.id AS module_id,
        form_modules.primero_module_id as primero_module_id,
        form_modules.form_section_id as form_section_id
      FROM form_sections_primero_modules as form_modules
      LEFT JOIN primero_modules AS modules
      ON form_modules.primero_module_id = modules.id
      LEFT JOIN form_sections as forms
      ON form_modules.form_section_id = forms.id
      WHERE (modules.id IS NULL AND form_modules.primero_module_id IS NOT NULL)
      OR (forms.id IS NULL AND form_modules.form_section_id IS NOT NULL)

    ),
    foreign_keys_map: {
      primero_module_id: 'module_id',
      form_section_id: 'form_id'
    },
    join_table: true
  },
  form_sections_roles: {
    sql: %(
      SELECT
        forms.id AS form_id,
        roles.id AS roles_role_id,
        form_roles.role_id,
        form_roles.form_section_id
      FROM form_sections_roles AS form_roles
      LEFT JOIN roles
      ON form_roles.role_id = roles.id
      LEFT JOIN form_sections AS forms
      ON form_roles.form_section_id = forms.id
      WHERE (roles.id IS NULL AND form_roles.role_id IS NOT NULL)
      OR (forms.id IS NULL AND form_roles.form_section_id IS NOT NULL)
    ),
    foreign_keys_map: {
      role_id: 'roles_role_id',
      form_section_id: 'form_id'
    },
    join_table: true
  },
  fields: {
    sql: %(
      SELECT
        fields.id AS id,
        fields.form_section_id AS form_section_id,
        forms.id AS form_id
      FROM fields
      LEFT join form_sections AS forms
      ON forms.id = fields.form_section_id
      WHERE forms.id IS NULL AND fields.form_section_id IS NOT NULL
    ),
    foreign_keys_map: {
      form_section_id: 'form_id'
    },
    primary_key: 'id'
  },
  traces: {
    sql: %(
      SELECT
        traces.id,
        requests.id AS requests_id,
        cases.id AS cases_id,
        traces.tracing_request_id  AS tracing_request_id,
        traces.matched_case_id  AS matched_case_id
      FROM traces
      LEFT JOIN tracing_requests AS requests
        ON traces.tracing_request_id = requests.id
      LEFT JOIN cases
        ON cases.id = traces.matched_case_id
      WHERE (cases.id IS NULL AND traces.matched_case_id IS NOT NULL)
      OR (requests.id IS NULL AND traces.tracing_request_id IS NOT NULL)
    ),
    foreign_keys_map: {
      tracing_request_id: 'requests_id',
      matched_case_id: 'cases_id'
    },
    primary_key: 'id'
  },
  alerts: {
    sql: %(
      SELECT
        alerts.id AS id,
        users.id AS users_user_id,
        agencies.id AS agencies_agency_id,
        alerts.user_id,
        alerts.agency_id
      FROM alerts
      LEFT JOIN users
        ON users.id = alerts.user_id
      LEFT JOIN agencies
        ON agencies.id = alerts.agency_id
      WHERE (users.id IS NULL AND alerts.user_id IS NOT NULL)
      OR (agencies.id IS NULL AND alerts.agency_id IS NOT NULL)
    ),
    foreign_keys_map: {
      user_id: 'users_user_id',
      agency_id: 'agencies_agency_id'
    },
    primary_key: 'id'
  },
  saved_searches: {
    sql: %(
      SELECT
        users.id AS users_user_id,
        searches.user_id,
        searches.id AS id
      FROM saved_searches searches
      LEFT JOIN users
        ON users.id = searches.user_id
      WHERE users.id IS NULL AND searches.user_id IS NOT NULL
    ),
    foreign_keys_map: {
      user_id: 'users_user_id'
    },
    primary_key: 'id'
  },
  incidents: {
    sql: %(
      SELECT
        incidents.id,
        cases.id AS case_id,
        incidents.incident_case_id
      FROM incidents
      LEFT JOIN cases ON cases.id = incidents.incident_case_id
      WHERE cases.id IS NULL AND incidents.incident_case_id IS NOT NULL
    ),
    foreign_keys_map: {
      incident_case_id: 'case_id'
    },
    primary_key: 'id'
  },
  cases: {
    sql: %(
      SELECT
        cases.id AS id,
        duplicates.id AS duplicate_id,
        registries.id AS registry_id,
        cases.duplicate_case_id,
        cases.registry_record_id
      FROM cases
      LEFT JOIN cases AS duplicates
      ON cases.duplicate_case_id = duplicates.id
      LEFT JOIN registry_records registries
      ON cases.registry_record_id  = registries.id
      WHERE (duplicates.id IS NULL AND cases.duplicate_case_id IS NOT NULL)
      OR (registries.id IS NULL AND cases.registry_record_id IS NOT NULL)
    ),
    foreign_keys_map: {
      duplicate_case_id: 'duplicate_id',
      registry_record_id: 'registry_id'
    },
    primary_key: 'id'
  },
  agencies_user_groups: {
    sql: %(
      SELECT
        agencies_groups.id AS id,
        agencies.id AS agencies_pk_id,
        user_groups.id AS group_pk_id,
        agencies_groups.user_group_id,
        agencies_groups.agency_id
      FROM agencies_user_groups agencies_groups
      LEFT JOIN agencies ON agencies_groups.agency_id = agencies.id
      LEFT JOIN user_groups ON agencies_groups.user_group_id  = user_groups.id
      WHERE (agencies.id IS NULL AND agencies_groups.agency_id IS NOT NULL)
      OR (user_groups.id IS NULL AND agencies_groups.user_group_id IS NOT NULL)
    ),
    foreign_keys_map: {
      user_group_id: 'group_pk_id',
      agency_id: 'agencies_pk_id'
    },
    primary_key: 'id',
    join_table: true
  },
  user_groups_users: {
    sql: %(
      SELECT
        users.id as user_pk,
        user_groups.id as user_group_pk,
        user_groups_users.id as id,
        user_groups_users.user_group_id,
        user_groups_users.user_id
      FROM user_groups_users
      LEFT JOIN users ON user_groups_users.user_id = users.id
      LEFT JOIN user_groups ON user_groups_users.user_group_id  = user_groups.id
      WHERE (users.id IS NULL AND user_groups_users.user_id IS NOT NULL)
      OR (user_groups.id IS NULL AND user_groups_users.user_group_id IS NOT NULL)
    ),
    foreign_keys_map: {
      user_group_id: 'user_group_pk',
      user_id: 'user_pk'
    },
    primary_key: 'id',
    join_table: true
  },
  perpetrators_violations: {
    sql: %(
      SELECT
        perpetrators_violations.id,
        perpetrators_violations.perpetrator_id,
        perpetrators_violations.violation_id,
        perpetrators.id AS perpetrator_pk,
        violations.id AS violations_pk
      FROM perpetrators_violations
      LEFT JOIN perpetrators ON perpetrators.id = perpetrators_violations.perpetrator_id
      LEFT JOIN violations ON violations.id = perpetrators_violations.violation_id
      WHERE (perpetrators.id IS NULL AND perpetrators_violations.perpetrator_id IS NOT NULL)
      OR (violations.id IS NULL AND perpetrators_violations.violation_id IS NOT NULL)
    ),
    foreign_keys_map: {
      perpetrator_id: 'perpetrator_pk',
      violation_id: 'violations_pk'
    },
    primary_key: 'id',
    join_table: true
  },
  individual_victims_violations: {
    sql: %(
      SELECT
        individual_victims_violations.id,
        individual_victims_violations.individual_victim_id,
        individual_victims_violations.violation_id,
        individual_victims.id AS individual_victims_pk,
        violations.id AS violations_pk
      FROM individual_victims_violations
      LEFT JOIN individual_victims ON individual_victims.id = individual_victims_violations.individual_victim_id
      LEFT JOIN violations ON violations.id  = individual_victims_violations.violation_id
      WHERE (individual_victims.id IS NULL AND individual_victims_violations.individual_victim_id IS NOT NULL)
      OR (violations.id IS NULL AND individual_victims_violations.violation_id IS NOT NULL)
    ),
    foreign_keys_map: {
      individual_victim_id: 'individual_victims_pk',
      violation_id: 'violations_pk'
    },
    primary_key: 'id',
    join_table: true
  },
  group_victims_violations: {
    sql: %(
      SELECT
        group_victims_violations.id,
        group_victims_violations.group_victim_id,
        group_victims_violations.violation_id,
        group_victims.id AS group_victims_pk,
        violations.id AS violations_pk
      FROM group_victims_violations
      LEFT JOIN group_victims ON group_victims.id = group_victims_violations.group_victim_id
      LEFT JOIN violations ON violations.id  = group_victims_violations.violation_id
      WHERE (group_victims.id IS NULL AND group_victims_violations.group_victim_id IS NOT NULL)
      OR (violations.id IS NULL AND group_victims_violations.violation_id IS NOT NULL)
    ),
    foreign_keys_map: {
      group_victim_id: 'group_victims_pk',
      violation_id: 'violations_pk'
    },
    primary_key: 'id',
    join_table: true
  },
  users: {
    sql: %(
      SELECT
        users.id,
        users.agency_id,
        users.role_id,
        users.identity_provider_id,
        agencies.id as agency_pk,
        roles.id as role_pk,
        identity_providers.id as identity_provider_pk
      FROM users
      LEFT JOIN agencies ON agencies.id = users.agency_id
      LEFT JOIN roles ON roles.id = users.role_id
      LEFT JOIN identity_providers  ON identity_providers.id = users.identity_provider_id
      WHERE (agencies.id IS NULL AND users.agency_id IS NOT NULL)
      OR (roles.id IS NULL AND users.role_id  IS NOT NULL)
      OR (identity_providers.id IS NULL AND users.identity_provider_id IS NOT NULL)
    ),
    foreign_keys_map: {
      role_id: 'role_pk',
      identity_provider_id: 'identity_provider_pk',
      agency_id: 'agency_pk'
    },
    primary_key: 'id'
  }
}.freeze

fix_records = ARGV[0] == 'true'

def execute_query(query)
  ActiveRecord::Base.connection.exec_query(query).to_a
end

def show_orphan_keys(table_config, result)
  table_config[:foreign_keys_map].entries.each do |(foreign_key, table_key)|
    next unless result[foreign_key.to_s].present? && result[table_key].nil?

    print_orphan_detail(result, table_config[:primary_key], foreign_key)
  end
end

def delete_orphan_join_record(table_name, table_config, result)
  puts 'Deleting orphan record in join table...'
  foreign_key_values = table_config[:foreign_keys_map].keys.reduce([]) do |memo, foreign_key|
    memo + [
      ActiveRecord::Base.sanitize_sql_for_conditions(
        ["#{ActiveRecord::Base.connection.quote_column_name(foreign_key)} = ?", result[foreign_key.to_s]]
      )
    ]
  end

  execute_query(
    ActiveRecord::Base.sanitize_sql_for_conditions(
      [
        %(
          DELETE FROM #{ActiveRecord::Base.connection.quote_table_name(table_name)}
          WHERE #{foreign_key_values.join(' AND ')}
        )
      ]
    )
  )
end

def nullify_orphan_foreign_keys(table_name, table_config, result)
  puts 'Setting orphan foreign keys to null...'
  table_config[:foreign_keys_map].entries.each do |(foreign_key, table_key)|
    next unless result[foreign_key.to_s].present? && result[table_key].nil?

    execute_query(
      ActiveRecord::Base.sanitize_sql_for_conditions(
        [
          %(
            UPDATE #{ActiveRecord::Base.connection.quote_table_name(table_name)}
            SET #{ActiveRecord::Base.connection.quote_column_name(foreign_key)} = NULL
            WHERE #{ActiveRecord::Base.connection.quote_column_name(foreign_key)} = ?
          ),
          result[foreign_key.to_s]
        ]
      )
    )
  end
end

def fix_orphan_record(table_name, table_config, result)
  if table_config[:join_table] == true
    delete_orphan_join_record(table_name, table_config, result)
  else
    nullify_orphan_foreign_keys(table_name, table_config, result)
  end
end

def print_orphan_detail(orphan, primary_key, foreign_key)
  foreign_key_value = orphan[foreign_key.to_s]

  if primary_key.present?
    puts(
      "With #{primary_key} = #{orphan[primary_key]}, non-existent foreign_key #{foreign_key} = #{foreign_key_value}"
    )
  else
    puts("#{foreign_key} = #{foreign_key_value} does not exists.")
  end
end

puts('==Checking foreign key constraints===')

ORPHANS_MAP.entries.each do |(key, value)|
  puts("\nChecking table: #{key}...")

  results = execute_query(value[:sql])

  puts('No primary key defined.') if value[:primary_key].blank?

  if results.present?
    if fix_records == true
      puts('Fixing orphan records...')
    else
      puts('The following records are orphaned:')
    end

    results.each do |result|
      if fix_records == true
        fix_orphan_record(key, value, result)
      else
        show_orphan_keys(value, result)
      end
    end
    puts('Done.')
  else
    puts('---No orphans found---')
  end
end
