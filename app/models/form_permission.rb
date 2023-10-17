# frozen_string_literal: true

# This table is used as has_many between form_section and roles
class FormPermission < ApplicationRecord
  # Use a custom table name, 'form_sections_roles,' indicating it's a join table.
  self.table_name = 'form_sections_roles'

  # Associations:
  belongs_to :form_section
  # 'touch: true' updates the 'updated_at' timestamp of the associated role when this permission is modified.
  belongs_to :role, touch: true

  # Define a mapping of permission levels to their respective abbreviations.
  PERMISSIONS = {
    read:       'r' , # read-only access.
    read_write: 'rw'  # 'rw' indicates both read and write (read-write) access.
  }.freeze
end
