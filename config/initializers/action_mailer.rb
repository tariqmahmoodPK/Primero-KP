# frozen_string_literal: true

require "#{Rails.root}/app/services/config_yaml_loader.rb"

# email_settings = ConfigYamlLoader.load(Rails.root.join('config', 'mailers.yml'))

Rails.application.config.action_mailer.tap do |action_mailer|
  action_mailer.delivery_method = :smtp
  action_mailer.default_options = { from: 'noreply@septemsystems.com' }
  action_mailer.smtp_settings = {
    user_name: 'apikey',
    password: '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',
    address: 'smtp.sendgrid.net',
    port: 587,
    domain: 'kpk.cpims.org.pk',
    authentication: 'login',
    enable_starttls_auto: true
  }
  action_mailer.raise_delivery_errors = true
  action_mailer.perform_deliveries = true
end

ActionMailer::Base.default_url_options = {
  host: 'kpk.cpims.org.pk',
  protocol: 'https'
}
