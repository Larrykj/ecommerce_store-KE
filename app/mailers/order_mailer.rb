# frozen_string_literal: true

class OrderMailer < ApplicationMailer
  default from: ENV.fetch("MAIL_FROM", "no-reply@larrycommerce.com")

  def confirmation
    @order = params[:order]
    @user = @order.user

    mail(to: @order.email, subject: "Order Confirmation - ##{@order.id}")
  end

  def status_updated
    @order = params[:order]
    @user = @order.user
    @status_label = OrderService.status_label(@order.status)

    mail(to: @order.email, subject: "Order ##{@order.id} - #{@status_label}")
  end

  def shipped
    @order = params[:order]
    @user = @order.user

    mail(to: @order.email, subject: "Your order ##{@order.id} has shipped!")
  end
end
