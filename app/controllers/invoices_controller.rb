# frozen_string_literal: true

class InvoicesController < ApplicationController
  before_action :authenticate_user!

  def show
    @order = current_user.orders.find(params[:order_id])

    respond_to do |format|
      format.html
      format.pdf do
        pdf = InvoicePdf.new(@order)
        send_data pdf.render,
                  filename: "invoice_#{@order.id}.pdf",
                  type: "application/pdf",
                  disposition: "inline"
      end
    end
  end
end
