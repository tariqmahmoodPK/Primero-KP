require 'erb'

class ContentGeneratorService
  def self.generate_message_content(file_path, message_params = nil)
    @case_record = message_params.dig('case')
    @case_id = @case_record.short_id || message_params.dig('case_id')

    @cpo_user = message_params.dig('cpo_user')
    @cpo_user_name = @cpo_user.user_name || message_params.dig('cpo_user_name')

    @scw_psy_user = message_params.dig('scw_psy_user')
    @scw_psy_user_name = @scw_psy_user.user_name || message_params.dig('scw_psy_user_name')

    @transfered_by_user = message_params.dig('transfered_by_user')
    @transfered_by_user_name = @transfered_by_user.user_name || message_params.dig('transfered_by_user_name')

    @location = message_params.dig('location')
    @workflow_stage = message_params.dig('workflow_stage')

    specific_body_content = File.read("#{Rails.root}/#{file_path}")

    erb_specific_body = ERB.new(specific_body_template)
    specific_body_content = erb_specific_body.result(binding)
  end
end
