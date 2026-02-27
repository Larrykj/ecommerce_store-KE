# frozen_string_literal: true

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :initialize_cart

  # POST /webhooks/stripe
  def stripe
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = if endpoint_secret.present?
                Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
              else
                JSON.parse(payload, symbolize_names: true)
              end
    rescue JSON::ParserError, Stripe::SignatureVerificationError => e
      Rails.logger.error "Webhook error: #{e.message}"
      head :bad_request
      return
    end

    case event[:type] || event.type
    when "checkout.session.completed"
      handle_checkout_completed(event[:data][:object] || event.data.object)
    when "payment_intent.succeeded"
      handle_payment_succeeded(event[:data][:object] || event.data.object)
    when "payment_intent.payment_failed"
      handle_payment_failed(event[:data][:object] || event.data.object)
    when "charge.refunded"
      handle_refund(event[:data][:object] || event.data.object)
    end

    head :ok
  end

  private

  def handle_checkout_completed(session)
    order = Order.find_by(stripe_checkout_session_id: session[:id] || session.id)
    return unless order

    if order.payment_pending?
      order.update!(payment_status: "paid", status: "processing")

      # Send confirmation email
      OrderMailer.with(order: order).confirmation.deliver_later
    end

    transaction = order.transactions.find_by(stripe_checkout_session_id: session[:id] || session.id)
    transaction&.update!(
      stripe_payment_intent_id: session[:payment_intent] || session.payment_intent,
      status: "succeeded",
      payment_method: "card"
    )
  end

  def handle_payment_succeeded(payment_intent)
    transaction = Transaction.find_by(stripe_payment_intent_id: payment_intent[:id] || payment_intent.id)
    transaction&.update!(status: "succeeded")
  end

  def handle_payment_failed(payment_intent)
    transaction = Transaction.find_by(stripe_payment_intent_id: payment_intent[:id] || payment_intent.id)
    if transaction
      transaction.update!(
        status: "failed",
        error_message: payment_intent[:last_payment_error]&.dig(:message) || "Payment failed"
      )
      transaction.order.update!(payment_status: "unpaid", status: "cancelled")
    end
  end

  def handle_refund(charge)
    payment_intent_id = charge[:payment_intent] || charge.payment_intent
    transaction = Transaction.find_by(stripe_payment_intent_id: payment_intent_id)
    return unless transaction

    refund_total = (charge[:amount_refunded] || charge.amount_refunded).to_d / 100
    transaction.update!(
      refund_amount: refund_total,
      refunded_at: Time.current,
      status: refund_total >= transaction.amount ? "refunded" : "partially_refunded"
    )
  end
end
