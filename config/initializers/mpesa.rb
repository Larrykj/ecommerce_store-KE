# frozen_string_literal: true

# MPesa Daraja API Configuration
# Uses direct HTTP calls to Safaricom's API — no external gem required.
Rails.application.config.mpesa = {
  consumer_key: ENV.fetch("MPESA_CONSUMER_KEY", ""),
  consumer_secret: ENV.fetch("MPESA_CONSUMER_SECRET", ""),
  shortcode: ENV.fetch("MPESA_SHORTCODE", ""),
  passkey: ENV.fetch("MPESA_PASSKEY", ""),
  environment: ENV.fetch("MPESA_ENVIRONMENT", "sandbox")
}
