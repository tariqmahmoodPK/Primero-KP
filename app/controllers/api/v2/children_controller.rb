# frozen_string_literal: true

# Main API controller for Case records
class Api::V2::ChildrenController < ApplicationApiController
  include Api::V2::Concerns::Pagination
  include Api::V2::Concerns::Record
  after_action :send_email_for_note, only: [:update], if: :note_params_present?


  def traces
    authorize! :read, Child
    record = Child.includes(:matched_traces).find(params[:case_id])
    authorize! :read, record
    @traces = record.matched_traces
    render 'api/v2/traces/index'
  end

  alias select_updated_fields_super select_updated_fields
  def select_updated_fields
    changes = @record.saved_changes_to_record.keys
    @updated_field_names = select_updated_fields_super + @record.current_care_arrangements_changes(changes)
  end

  private

  def note_params_present?
    record_params["notes_section"].present?
  end

  def send_email_for_note
    cpo_user = User.joins(:role).where(role: { unique_id: "role-cp-administrator" }).find_by(location: @record.data["owned_by_location"])

    CaseLifecycleEventsNotificationMailer.send_case_query_notification(@record, cpo_user).deliver_later

    if cpo_user&.phone
      message_params = {
        case: @record,
        user: cpo_user,
        workflow_stage: @record.data["workflow"]
      }.with_indifferent_access

      file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_flags_notification.text.erb"
      message_content = ContentGeneratorService.generate_message_content(file_path, message_params)
      twilio_service = TwilioWhatsappService.new
      to_phone_number = cpo_user.phone
      message_body = message_content

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end
end
