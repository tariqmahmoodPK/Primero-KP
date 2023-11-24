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

    # User.joins(user_groups: { users: :role }):
      # This part sets up the SQL join, starting from the User model and joining UserGroup, User, and Role tables.
    # user_groups: { users: { id: user.id } }:
      # It ensures that we only consider user groups to which the given user (user) belongs.
    # roles: { unique_id: "role-cp-administrator" }:
      # It filters for the role with the unique ID "role-cp-administrator."
    #

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    cpo_users_emails = cpo_users.pluck(:email)

    @case_id = case_record

    if cpo_users_emails.present?
      mail(to: cpo_users_emails, subject: 'Case Registration Completed') do |format|
        format.html { render 'send_case_registration_completed_notification' }
        format.text { render 'send_case_registration_completed_notification' }
      end
    else
      Rails.logger.warn("No CPOs found for case registration completion notification.")
    end
  end

  def send_case_registration_verified_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    @owned_by_user_name = case_record.data['owned_by']
    user = User.find_by(user_name: @owned_by_user_name)

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    cpo_users_emails = cpo_users.pluck(:email)

    @case_id = case_record

    @cpo_user = cpo_users[0]

    if cpo_users_emails.present?
      mail(to: cpo_users_emails, subject: 'Case Registration Verified') do |format|
        format.html { render 'send_case_registration_verified_notification' }
        format.text { render 'send_case_registration_verified_notification' }
      end
    else
      Rails.logger.warn("No CPOs found for case registration verification notification.")
    end
  end
  end
end
