# frozen_string_literal: true

# The "Flaggable" module is designed for records that can have flags applied to them. Flags provide a way to
# mark and categorize records for various purposes. This module includes methods for adding and removing flags,
# counting flagged records, and more.
module Flaggable
  extend ActiveSupport::Concern
  include Sunspot::Rails::Searchable

  included do
    # Define how flaggable records should be indexed for searching.
    searchable do
      boolean :flagged
    end

    has_many :flags, as: :record
    has_many :active_flags, -> { where(removed: false) }, as: :record, class_name: 'Flag'
  end

  # Adds a flag to the current record, including details like the message, date, and user who flagged it.
  def add_flag(message, date, user_name)
    date_flag = date.presence || Date.today
    flag = Flag.new(flagged_by: user_name, message: message, date: date_flag, created_at: DateTime.now)
    flags << flag
    flag
  end

  # Removes a flag from the record with the specified ID, providing information about who removed it and a message.
  def remove_flag(id, user_name, unflag_message)
    flag = flags.find_by(id: id)
    return unless flag.present?

    flag.unflag_message = unflag_message
    flag.unflagged_date = Date.today
    flag.unflagged_by = user_name
    flag.removed = true
    flag.save!
    flag
  end

  # Retrieves the count of active flags (flags that haven't been removed) for the current record.
  def flag_count
    active_flags.size
  end

  # Checks if the record is flagged by verifying if it has any active flags.
  def flagged?
    flag_count.positive?
  end
  alias flagged flagged?

  # Module for ClassMethods
  module ClassMethods
    # Flags a batch of records with a message, date, and the user responsible for flagging them.
    def batch_flag(records, message, date, user_name)
      ActiveRecord::Base.transaction do
        records.each do |record|
          record.add_flag(message, date, user_name)
        end
      end
    end
  end
end
