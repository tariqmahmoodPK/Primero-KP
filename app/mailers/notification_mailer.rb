# frozen_string_literal: true

# Sends email notifications for Approval requests and responses,
# Transition notification, and Transfer Requests.
# TODO: Break up into separate mailers.
class NotificationMailer < ApplicationMailer
  helper :application

  def manager_approval_request(record_id, approval_type, manager_user_name)
    @manager = User.find_by(user_name: manager_user_name) || (return log_not_found('Manager user', manager_user_name))
    @child = Child.find_by(id: record_id) || (return log_not_found('Case', record_id))
    @user = @child.owner || (return log_not_found('User', @child.owned_by))
    @approval_type = Lookup.display_value('lookup-approval-type', approval_type)
    @locale_email = @manager.locale || I18n.locale
    return unless assert_notifications_enabled(@manager)

    mail(to: @manager.email, subject: t('email_notification.approval_request_subject', id: @child.short_id,
                                                                                       locale: @locale_email))
  end

  def manager_approval_response(record_id, approved, approval_type, manager_user_name)
    @child = Child.find_by(id: record_id) || (return log_not_found('Case', record_id))
    @owner = @child.owner || (return log_not_found('User', @child.owned_by))
    return unless assert_notifications_enabled(@owner)

    load_manager_approval_request(approved, approval_type, manager_user_name)
    mail(to: @owner.email,
         subject: t('email_notification.approval_response_subject', id: @child.short_id, locale: @locale_email))
  end

  # 1-b
  # Case Assigned to SCW/Psychologist # And other Notifications too
  def transition_notify(transition_id)
    load_transition_for_email(Transition, transition_id)
    return log_not_found('Transition', transition_id) unless @transition

    if assert_notifications_enabled(@transition&.transitioned_to_user)
      mail(to: @transition&.transitioned_to_user&.email, subject: transition_subject(@transition&.record))
    end

    cpo_user = User.joins(:role).where(role: { unique_id: "role-cp-administrator" }).find_by(user_name: @transition.transitioned_by)

    # Send Whatsapp Notification
    if @transition.key == "assign" && cpo_user.present? && cpo_user&.phone
      message_params = {
        case: @transition&.record,
        cpo_user: cpo_user,
      }.with_indifferent_access

      file_path = "app/views/case_lifecycle_events_notification_mailer/send_case_registered_scw_psychologist_notification.text.erb"
      message_content = ContentGeneratorService.generate_message_content(file_path, message_params)

      twilio_service = TwilioWhatsAppService.new
      to_phone_number = cpo_user.phone
      message_body = message_content

      twilio_service.send_whatsapp_message(to_phone_number, message_body)
    end
  end

  def transfer_request(transfer_request_id)
    load_transition_for_email(TransferRequest, transfer_request_id)
    return log_not_found('Transfer Request Transition', transfer_request_id) unless @transition
    return unless assert_notifications_enabled(@transition&.transitioned_to_user)

    mail(
      to: @transition&.transitioned_to_user&.email,
      subject: t('email_notification.transfer_request_subject'),
      locale: @locale_email
    )
  end

  private

  def log_not_found(type, id)
    Rails.logger.error(
      "Mail not sent. #{type.capitalize} #{id} not found."
    )
  end

  def assert_notifications_enabled(user)
    return true if user&.emailable?

    Rails.logger.info("Mail not sent. Notifications disabled for #{user&.user_name || 'nil user'}")

    false
  end

  def manager_approval_message
    t('approvals.status.approved', locale: @locale_email)
  end

  def manager_rejected_message
    t('approvals.status.rejected', locale: @locale_email)
  end

  def load_manager_approval_request(approved, approval_type, manager_user_name)
    @manager = User.find_by(user_name: manager_user_name)
    lookup_name = @manager.gbv? ? 'lookup-gbv-approval-types' : 'lookup-approval-type'
    @approval_type = Lookup.display_value(lookup_name, approval_type)
    @locale_email = @owner.locale || I18n.locale
    @approval = approved ? manager_approval_message : manager_rejected_message
  end

  def load_transition_for_email(class_transition, id)
    @transition = class_transition.find_by(id: id)
    @locale_email = @transition&.transitioned_to_user&.locale || I18n.locale
  end

  def transition_subject(record)
    t(
      "email_notification.#{@transition.key}_subject",
      record_type: t("forms.record_types.#{record.class.parent_form}", locale: @locale_email),
      id: record.short_id,
      locale: @locale_email
    )
  end
end
