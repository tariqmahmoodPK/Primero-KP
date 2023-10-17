# frozen_string_literal: true

class CreatePreventions < ActiveRecord::Migration[6.1]
  enable_extension 'pgcrypto' unless ENV['PRIMERO_PG_APP_ROLE'] || extension_enabled?('pgcrypto')

  def change
    create_table :preventions, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.jsonb 'data', default: {}
      t.index "((data ->> 'prevention_id'::text))", name: "preventions_prevention_id_unique_idx", unique: true
      t.index ["data"], name: "index_preventions_on_data", using: :gin

      t.timestamps
    end
  end
end
