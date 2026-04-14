# frozen_string_literal: true

class Api::V1::PaymentsController < Api::V1::BaseController
  SUPPORTED_CURRENCIES = %w[kes].freeze
  DEFAULT_PAYMENT_AMOUNT = 1000
  def create_intent
    amount = payment_amount_cents
    currency = validated_currency
    begin
      intent = Stripe::PaymentIntent.create({
        amount: amount,
        currency: currency,
        automatic_payment_methods: { enabled: true }
      })
      publishable_key = ENV["STRIPE_PUBLISHABLE_KEY"] || Rails.application.credentials.dig(:stripe, :publishable_key)
      if publishable_key.blank?
        render_api_error(
          code: "stripe_publishable_key_missing",
          message: "Stripe publishable key is missing.",
          status: :internal_server_error
        )
        return
      end

      render json: {
        paymentIntent: intent.client_secret,
        publishableKey: publishable_key
      }
    rescue ActionController::ParameterMissing, ArgumentError => e
      render_api_error(
        code: "invalid_payment_request",
        message: e.message,
        status: :unprocessable_entity
      )
    rescue Stripe::StripeError => e
      render_api_error(
        code: "stripe_error",
        message: e.message,
        status: :unprocessable_entity
      )
    end
  end

  private

  def payment_amount_cents
    # Compute this from server-side cart/order data for the authenticated user.
    # Do not trust client-provided amounts.
    DEFAULT_PAYMENT_AMOUNT
  end

  def validated_currency
    currency = params.fetch(:currency, "kes").to_s.downcase
    unless SUPPORTED_CURRENCIES.include?(currency)
      raise ArgumentError, "Unsupported currency"
    end
    currency
  end
end
