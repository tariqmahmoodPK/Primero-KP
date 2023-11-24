class CaseLifecycleEventsNotificationMailer < ApplicationMailer
  def send_case_registered_notification(case_record, cpo_user)
    @case_id = case_record
    @cpo_user = cpo_user

    mail(to: @cpo_user.email, subject: 'Case Registration through Helpline (CPHO)') do |format|
      format.html { render 'send_case_registered_notification' }
      format.text { render 'send_case_registered_notification' }
    end
  end

  def send_case_registration_completed_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    @owned_by_user_name = case_record.data['owned_by']
    user = User.find_by(user_name: @owned_by_user_name)
    user_groups = user.user_groups
    cpo_users = user_groups.joins(users: :role).where(roles: { unique_id: "role-cp-administrator" })
    cpo_users_emails = cpo_users.pluck(:email)

    @case_id = case_record

    if cpo_users_emails.present?
      mail(to: cpo_users_emails, subject: 'Case Registration through Helpline (CPHO)') do |format|
        format.html { render 'send_case_registration_completed_notification' }
        format.text { render 'send_case_registration_completed_notification' }
      end
    else
      Rails.logger.warn("No CPOs found for case registration notification.")
    end
  end
  end
end
