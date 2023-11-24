class CaseLifecycleEventsNotificationMailer < ApplicationMailer
  def send_case_registered_notification(case_record, cpo_user)
    @case_id = case_record
    @cpo_user = cpo_user

    mail(to: @cpo_user.email, subject: 'Case Registration through Helpline (CPHO)') do |format|
      format.html { render 'send_case_registered_notification' }
      format.text { render 'send_case_registered_notification' }
    end
  end

  def send_case_registration_completed_notification(case_record, cpo_user, owned_by_user_name)
    @case_id = case_record
    @cpo_user = cpo_user
    @owned_by_user_name = owned_by_user_name

    mail(to: @cpo_user.email, subject: 'Case Registration through Helpline (CPHO)') do |format|
      format.html { render 'send_case_registration_completed_notification' }
      format.text { render 'send_case_registration_completed_notification' }
    end
  end
end
