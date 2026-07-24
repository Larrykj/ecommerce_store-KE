# frozen_string_literal: true

class Api::V1::PaymentsController < Api::V1::BaseController
  SUPPORTED_CURRENCIES = %w[kes].freeze

  def create_intent
    amount = payment_amount_cents
    if amount <= 0
      render_api_error(
        code: "empty_order",
        message: "No pending order or cart found. Please add items before paying.",
        status: :unprocessable_entity
      )
      return
    end

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
    # Compute from server-side order/cart data — never trust client-provided amounts.
    # Priority: most recent pending order, then fall back to 0 (reject).
    pending_order = current_api_user.orders.where(payment_status: [ "unpaid", "pending" ]).order(created_at: :desc).first
    if pending_order
      (pending_order.total_price.to_d * 100).to_i
    else
      0
    end
  end

  def validated_currency
    currency = params.fetch(:currency, "kes").to_s.downcase
    unless SUPPORTED_CURRENCIES.include?(currency)
      raise ArgumentError, "Unsupported currency"
    end
    currency
  end
end
