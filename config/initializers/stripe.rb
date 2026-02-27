# frozen_string_literal: true

# Stripe Configuration
Stripe.api_key = ENV["STRIPE_SECRET_KEY"] || Rails.application.credentials.dig(:stripe, :secret_key)
STRIPE_PUBLISHABLE_KEY = ENV["STRIPE_PUBLISHABLE_KEY"] || Rails.application.credentials.dig(:stripe, :publishable_key)

# Currency for Stripe payments (ISO 4217 lowercase).
# Default to "usd" for broad test-mode compatibility.
# Set STRIPE_CURRENCY=kes in .env once your Stripe account supports KES.
STRIPE_CURRENCY = (ENV["STRIPE_CURRENCY"] || "usd").downcase.freeze
