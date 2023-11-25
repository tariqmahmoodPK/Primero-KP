class CaseLifecycleEventsNotificationMailer < ApplicationMailer
  # 1a
  # Case Registered | Case Reffered to CPO | Mail CPO
  # Case id | CPO User Email
  def send_case_registered_cpo_notification(case_record, cpo_user)
    @case_id = case_record
    @cpo_user = cpo_user

    mail(to: @cpo_user.email, subject: 'Case Registration through Helpline (CPHO)') do |format|
      format.html { render 'send_case_registered_cpo_notification' }
      format.text { render 'send_case_registered_cpo_notification' }
    end
  end

  # 1b
  # Case Registered | Case Assigned to SCW/Psychologist | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist User Email | CPO Name
  def send_case_registered_scw_psychologist_notification(case_record, cpo_user)

  end

  # 1a ii
  # Case Transfered | Transfered to CPO | Mail to CPO
  # Case id | Referrer Username | Referral Location | Workflow Stage
  def send_case_transfered_cpo_notification

  end

  # 1b ii
  # Case Transfered | Transfered to SCW/Psychologist | Mail to SCW/Psychologist
  # Case id | CPO Name | Transfer/Refffer Location | Workflow Stage
  def send_case_transfered_scw_psychologist_notification

  end

  # 2a
  # Case Registration Completed | Mail to CPO
  # Case id | SCW/Psychologist | CPO User Email
  def send_case_registration_completed_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    @user_name = case_record.data['owned_by']
    user = User.find_by(user_name: @user_name)

    # User.joins(user_groups: { users: :role }):
      # This part sets up the SQL join, starting from the User model and joining UserGroup, User, and Role tables.
    # user_groups: { users: { id: user.id } }:
      # It ensures that we only consider user groups to which the given user (user) belongs.
    # roles: { unique_id: "role-cp-administrator" }:
      # It filters for the role with the unique ID "role-cp-administrator."
    #

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    users_emails = cpo_users.pluck(:email)

    @case_id = case_record

    subject = "Case Registration Completed"

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 2b
  # Case Registration Verified | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_case_registration_verified_notification(case_record, current_user, declaration_value)
    # SCW/Psy
    user_name = case_record.data['owned_by']
    user = User.find_by(user_name: user_name)

    cpo_users = User.joins(user_groups: { users: :role }).where(user_groups: { users: { id: user.id } }, roles: { unique_id: "role-cp-administrator" }).distinct

    users_emails = cpo_users.pluck(:email)

    @case_id = case_record

    cpo_user = cpo_users[0]
    @user_name = @cpo_user.user_name

    subject = "Case Registration Verified"

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 3a
  # Initial Assessment Completed | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_initial_assessment_completed_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 3b
  # Initial Assessment Verified | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_initial_assessment_verified_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 4a
  # Comprehensive Assessment Completed | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_comprehensive_assessment_completed_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 4b
  # Comprehensive Assessment Verified | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_comprehensive_assessment_verified_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 5a
  # Case Plan Completed | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_case_plan_completed_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 5b
  # Case Plan Verified | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_case_plan_verified_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 6a
  # Alternative Care Placement Completed | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_alternative_care_placement_completed_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 6b
  # Alternative Care Placement | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_alternative_care_placement_verified_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 7a
  # Monitoring and Follow up Sub form | Mail to CPO
  # Case id | SCW/Psychologist Username | CPO Email
  def send_monitoring_and_follow_up_subform_completed_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 7b
  # Monitoring and Follow up Sub form | Mail to SCW/Psychologist
  # Case id | SCW/Psychologist Email | CPO Username
  def send_monitoring_and_follow_up_subform_verified_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 8a
  # Case Referred | Mail to some Recipient
  # Case id | SCW/Psychologist Username | Email of Recipient
  def send_case_referred_to_user_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 8b
  # Case Referred | Mail to some Recipient
  # Case id | SCW/Psychologist Username | Email of Recipient
  def send_case_referred_revoked_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end

  # 8c
  # Case Referred | Mail to SCW/Psychologist
  # Case id | Referral Partner Username | Email of SCW/Psychologist
  def send_case_referred_accepted_notification(case_record, current_user, declaration_value)

    if users_emails.present?
      mail(to: users_emails, subject: subject) do |format|
        format.html { render __method__.to_s }
        format.text { render __method__.to_s }
      end
    else
      Rails.logger.warn("No Emails Found.")
    end
  end
end
