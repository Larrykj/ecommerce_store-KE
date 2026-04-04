# frozen_string_literal: true

# WARNING: This controller returns mock Stripe credentials.
# Before going to production, implement real customer creation and ephemeral key generation.
class Api::V1::PaymentsController < Api::V1::BaseController
  def create_intent
    amount = params[:amount] || 1000
    currency = params[:currency] || "kes"

    begin
      intent = Stripe::PaymentIntent.create({
        amount: amount.to_i,
        currency: currency,
        automatic_payment_methods: { enabled: true },
      })

      render json: {
        paymentIntent: intent.client_secret,
        ephemeralKey: "mock_ephemeral_key",
        customer: "cus_mock123",
        publishableKey: ENV["STRIPE_PUBLISHABLE_KEY"] || Rails.application.credentials.dig(:stripe, :publishable_key)
      }
    rescue Stripe::StripeError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
