require 'erb'

class ContentGeneratorService
  def self.generate_message_content(file_path, message_params = nil)
    @case_record = message_params.dig('case')
    @case_id = @case_record.short_id || message_params.dig('case_id')
    @cpo_user = message_params.dig('cpo_user')

    specific_body_content = File.read("#{Rails.root}/#{file_path}")

    erb_specific_body = ERB.new(specific_body_template)
    specific_body_content = erb_specific_body.result(binding)
  end
end
