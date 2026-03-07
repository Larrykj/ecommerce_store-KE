# frozen_string_literal: true

module AdminAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin!, only: [ :create, :new, :edit, :update, :destroy ]
  end

  private

  def authenticate_admin!
    unless user_signed_in? && current_user.admin?
      redirect_to root_path, alert: I18n.t("admin_access_denied", default: "You do not have permission to access this resource.")
    end
  end

  def authorize_admin_for_resource!
    unless current_user&.admin?
      render json: { error: "Unauthorized" }, status: :forbidden
    end
  end
end
