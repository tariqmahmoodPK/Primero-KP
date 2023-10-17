# frozen_string_literal: true

# The "Attachable" module provides class methods for declaring attachments of types such as images, audio, and
# documents on records. It includes idiomatic methods for handling case photos and related functionalities.
module Attachable
  extend ActiveSupport::Concern
  include Sunspot::Rails::Searchable

  MAX_ATTACHMENTS = 100
  PHOTOS_FIELD_NAME = 'photos'
  AUDIOS_FIELD_NAME = 'recorded_audio'

  included do
    # Associations
    has_many :attachments   , -> { order('date DESC NULLS LAST') }, as: :record
    has_many :current_photos, -> { where(field_name: PHOTOS_FIELD_NAME).order('date DESC NULLS LAST') },
             as: :record, class_name: 'Attachment'
    has_many :current_audios, -> { where(field_name: AUDIOS_FIELD_NAME).order('date DESC NULLS LAST') },
             as: :record, class_name: 'Attachment'
    # Validations
    validate :maximum_attachments_exceeded

    # Define how attachable records should be indexed for searching.
    searchable do
      boolean :has_photo
    end
  end

  # Checks if the record has a photo by verifying if it has any current photos associated with it.
  def photo?
    # Because Matz
    # rubocop:disable Naming/MemoizedInstanceVariableName
    @has_photo ||= current_photos.size.positive?
    # rubocop:enable Naming/MemoizedInstanceVariableName
  end
  alias has_photo? photo?
  alias has_photo photo?

  # Retrieves the first current photo associated with the record.
  def photo
    @photo ||= current_photos.first
  end

  # Generates the URL for the first photo, allowing access to the photo's file.
  def photo_url
    return unless photo&.file

    Rails.application.routes.url_helpers.rails_blob_path(photo.file, only_path: true)
  end

  private

  # Validates that the maximum number of attachments on the record does not exceed the predefined limit.
  def maximum_attachments_exceeded
    return unless attachments.size > (MAX_ATTACHMENTS - 1)

    errors.add(:attachments, 'errors.attachments.maximum')
  end
end
