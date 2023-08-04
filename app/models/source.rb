# frozen_string_literal: true

# Model for MRM Source
class Source < ApplicationRecord
  include ViolationAssociable

  has_and_belongs_to_many :violations
end
