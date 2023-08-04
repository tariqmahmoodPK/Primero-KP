# frozen_string_literal: true

class CreateAgenciesUserGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :agencies_user_groups do |t|
      t.belongs_to :agency, index: true
      t.belongs_to :user_group, index: true
    end
  end
end
