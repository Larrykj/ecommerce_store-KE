# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def create
    # First, try to find the user by their email
    user = User.find_by(email: params[:user][:email])

    # If the user exists and they signed up via a social provider (e.g., Google or GitHub),
    # but they are trying to log in using a regular password manually, they will fail
    # because their Devise password is randomized. We intercept this edge case to guide them.
    if user.present? && user.provider.present? && !user.valid_password?(params[:user][:password])
      # Flash a specific message guiding them to use the social login button
      flash.now[:alert] = "This account is linked to #{user.provider.capitalize}. Please click 'Continue with #{user.provider.capitalize}' below to sign in."
      
      # Stop the login process and re-render the login page with our friendly error
      self.resource = user
      render :new, status: :unprocessable_entity
      return
    end

    # Otherwise, proceed with the standard Devise authentication flow
    super
  end
end
