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
    # Getting location of current_user as the location of the cpo would be the same.
    location = @current_user.location
    # or
    # location = updated_record.data['owned_by_location']

    @case_id = case_record
    @owned_by_user_name = case_record.data['owned_by']
    # Getting cpo_user whose locaion matches the location
    @cpo_user = User.joins(:role).where(role: { unique_id: "role-cp-administrator" }).find_by(location: location)

    mail(to: @cpo_user.email, subject: 'Case Registration through Helpline (CPHO)') do |format|
      format.html { render 'send_case_registration_completed_notification' }
      format.text { render 'send_case_registration_completed_notification' }
    end
  end
end
