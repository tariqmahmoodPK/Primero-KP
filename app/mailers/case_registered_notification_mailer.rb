class CaseRegisteredNotificationMailer < ApplicationMailer
  def send_case_registered_notification(case_id, cpo_user)
    @case_id = case_id
    @cpo_user = cpo_user

    mail(to: @cpo_user.email, subject: 'Case Registration through Helpline (CPHO)') do |format|
      format.html { render 'send_case_registered_notification' }
      format.text { render 'send_case_registered_notification' }
    end
  end
end
