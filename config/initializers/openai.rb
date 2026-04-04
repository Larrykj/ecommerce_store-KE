# frozen_string_literal: true

openai_api_key = ENV["OPENAI_API_KEY"].presence || Rails.application.credentials.dig(:openai, :api_key)

if openai_api_key.present?
  OpenAI.configure do |config|
    config.access_token = openai_api_key
    config.log_errors = Rails.env.development?
  end
end
