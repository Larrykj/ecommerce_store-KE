# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :toggle_admin]

  def index
    @users = User.kept.order(created_at: :desc)
  end

  def show
    @orders = @user.orders.order(created_at: :desc)
  end

  def toggle_admin
    if @user == current_user
      redirect_to admin_users_path, alert: "You cannot change your own admin status."
    else
      @user.update(admin: !@user.admin?)
      redirect_to admin_users_path, notice: "#{@user.name} admin status updated."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
