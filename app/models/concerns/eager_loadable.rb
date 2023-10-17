# frozen_string_literal: true

# A shared concern for all Records that can be eagerloaded

# The "EagerLoadable" module is a shared concern for all records that can be eager-loaded. It provides a class method
# to define the associations to be eager-loaded, improving database query efficiency by reducing the number of queries
# required to retrieve associated records.
module EagerLoadable
  extend ActiveSupport::Concern

  # ClassMethods
  module ClassMethods
    # Returns the class with specified associations to be eager-loaded for more efficient database queries.
    def eager_loaded_class
      # @clazz.eager_load(:alerts, :attachments, :flags)
      includes(
        :alerts, :active_flags, attachments: { file_attachment: :blob }, current_photos: { file_attachment: :blob }
      )
    end
  end
end
