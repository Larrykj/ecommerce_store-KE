# frozen_string_literal: true

class SubscribersController < ApplicationController
  def create
    @subscriber = Subscriber.new(subscriber_params)
    @subscriber.name = current_user&.name

    if @subscriber.save
      redirect_back fallback_location: root_path, notice: "Thanks for subscribing! You'll receive our latest deals."
    else
      redirect_back fallback_location: root_path, alert: @subscriber.errors.full_messages.first || "Could not subscribe."
    end
  end

  def unsubscribe
    @subscriber = Subscriber.find_by(token: params[:token])
    if @subscriber
      @subscriber.unsubscribe!
    end
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end
end
