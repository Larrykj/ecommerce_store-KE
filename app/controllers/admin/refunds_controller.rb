# frozen_string_literal: true

class Admin::RefundsController < Admin::BaseController
  def create
    @order = Order.find(params[:order_id])
    @transaction = @order.transactions.successful.last

    unless @transaction
      redirect_to admin_order_path(@order), alert: "No successful payment found for this order."
      return
    end

    begin
      refund = Stripe::Refund.create(
        payment_intent: @transaction.stripe_payment_intent_id,
        amount: params[:amount].present? ? (params[:amount].to_d * 100).to_i : nil # nil = full refund
      )

      refund_amount = refund.amount.to_d / 100
      @transaction.update!(
        refund_amount: (@transaction.refund_amount || 0) + refund_amount,
        refunded_at: Time.current,
        status: refund_amount >= @transaction.amount ? "refunded" : "partially_refunded"
      )

      @order.update!(status: "cancelled") if @transaction.fully_refunded?

      redirect_to admin_order_path(@order), notice: "Refund of #{format_price(refund_amount)} processed successfully."
    rescue Stripe::StripeError => e
      redirect_to admin_order_path(@order), alert: "Refund failed: #{e.message}"
    end
  end
end
