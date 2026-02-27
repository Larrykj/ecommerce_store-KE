# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  default from: "no-reply@larrycommerce.com"

  def confirmation
    @order = params[:order]
    @user = @order.user

    mail(to: @order.email, subject: "Order Confirmation - ##{@order.id}")
  end

  def shipped
    @order = params[:order]
    @user = @order.user

    mail(to: @order.email, subject: "Your order ##{@order.id} has shipped!")
  end
end
