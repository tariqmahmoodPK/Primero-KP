# frozen_string_literal: true

# The "Approvable" module enhances records with request approval and approval capabilities. It allows
# records to store approval-related information, perform searches based on approval statuses and dates, and
# send approval request and response emails. This module is valuable for scenarios where records require
# approval workflows and communication with relevant personnel for reviewing and approving record changes.

# Records that use this module have request approval and approval capabilities
module Approvable
  extend ActiveSupport::Concern

  included do

    store_accessor :data                          , :assessment_approved           , :case_plan_approved          , :closure_approved          ,
                   :action_plan_approved          , :gbv_closure_approved          , :approval_status_assessment  , :approval_status_case_plan ,
                   :approval_status_closure       , :approval_status_action_plan   , :approval_status_gbv_closure , :case_plan_approval_type   ,
                   :assessment_approved_date      , :closure_approved_date         , :case_plan_approved_date     , :action_plan_approved_date ,
                   :gbv_closure_approved_date     , :assessment_approved_comments  , :case_plan_approved_comments , :closure_approved_comments ,
                   :action_plan_approved_comments , :gbv_closure_approved_comments , :approval_subforms

    searchable do
      # Define searchable fields for approval status.
      string :approval_status_assessment , as: 'approval_status_assessment_sci'
      string :approval_status_case_plan  , as: 'approval_status_case_plan_sci'
      string :approval_status_closure    , as: 'approval_status_closure_sci'
      string :approval_status_action_plan, as: 'approval_status_action_plan_sci'
      string :approval_status_gbv_closure, as: 'approval_status_gbv_closure_sci'
      string :case_plan_approval_type    , as: 'case_plan_approval_type_sci'

      # Define searchable fields for approval dates.
      date :case_plan_approved_date
      date :assessment_approved_date
      date :closure_approved_date
      date :action_plan_approved_date
      date :gbv_closure_approved_date
    end

    # Trigger a callback to send approval-related emails after saving a record with approval subforms.
    after_save_commit :send_approval_mail
  end

  # Sends approval-related emails after saving a record with approval subforms.
  def send_approval_mail
    return if approval_subforms.blank? || saved_changes_to_record.keys.exclude?('approval_subforms')

    # Retrieve the latest approval subform.
    approval = approval_subforms.last

    if approval['approval_requested_for'].present?
      send_approval_request_mail(approval)
    else
      send_approval_response_mail(approval)
    end
  end

  # Sends an approval request email to managers for approval.
  def send_approval_request_mail(approval)
    managers = owner.managers.select(&:emailable?)
    if managers.blank?
      Rails.logger.info "Approval Request Mail not sent. No managers present with send_mail enabled. User [#{owner.id}]"
      return
    end

    # Send approval request emails to eligible managers.
    managers.each { |manager| ApprovalRequestJob.perform_later(id, approval['approval_for_type'], manager.user_name) }
  end

  # Sends an approval response email after approval or rejection.
  def send_approval_response_mail(approval)
    ApprovalResponseJob.perform_later(id, send("#{approval['approval_response_for']}_approved"),
                                      approval['approval_for_type'], approval['approved_by'])
  end
end
