# frozen_string_literal: true

class SendTelegramMessage
  API_URL = "https://api.telegram.org"
  def call(chat_id, text)
    params = {chat_id: chat_id, text: text}
    Typhoeus.post("#{API_URL}/bot#{Rails.application.config.telegram_token}/sendMessage", params: params)
  end
end
