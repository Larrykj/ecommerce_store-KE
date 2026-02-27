# frozen_string_literal: true

class Admin::SubscribersController < Admin::BaseController
  def index
    @subscribers = Subscriber.order(created_at: :desc)
    @active_count = Subscriber.active.count
    @total_count = Subscriber.count
  end

  def destroy
    @subscriber = Subscriber.find(params[:id])
    @subscriber.destroy
    redirect_to admin_subscribers_path, notice: "Subscriber removed."
  end
end
