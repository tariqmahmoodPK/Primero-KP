require 'twilio-ruby'

class TwilioWhatsappService
  def initialize
    account_sid = ENV['TWILIO_ACCOUNT_SID']
    auth_token = ENV['TWILIO_AUTH_TOKEN']
    @client = Twilio::REST::Client.new(account_sid, auth_token)
  end

  def send_whatsapp_message(to, body)
    message = @client.messages.create(
      from: 'whatsapp:+14155238886',
      body: body,
      to: "whatsapp:#{to}"
    )

    puts "Message sent with SID: #{message.sid}"
  end
end
