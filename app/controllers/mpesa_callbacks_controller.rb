class MpesaCallbacksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  # MPesa STK push callback endpoint
  def create
    # Read nested JSON payload safely without mass-assignment risks
    stk_callback = params.dig("Body", "stkCallback") || params.dig(:Body, :stkCallback)
    if stk_callback
      checkout_request_id = stk_callback["CheckoutRequestID"]
      result_code = stk_callback["ResultCode"]
      result_desc = stk_callback["ResultDesc"]

      order = Order.find_by(payment_reference: checkout_request_id)
      if order
        if result_code == 0
          order.update!(payment_status: "completed", payment_provider: "mpesa")
        else
          order.update!(payment_status: "failed", payment_provider: "mpesa")
        end
      end
    end
    head :ok
  end
end
