# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth("Google")
  end

  def github
    handle_auth("GitHub")
  end

  def failure
    redirect_to root_path, alert: "Authentication failed. Please try again."
  end

  private

  def handle_auth(provider)
    auth = request.env["omniauth.auth"]
    
    email = auth.info.email
    email = "#{auth.uid}@#{provider.downcase}.com" if email.blank?

    # Standard fix for "Email has already been taken" when mixing social & normal logins
    @user = User.find_by(email: email)
    
    if @user
      # Link social account if not already linked
      @user.update(provider: auth.provider, uid: auth.uid) if @user.provider.blank?
    else
      @user = User.new(
        email: email,
        password: Devise.friendly_token[0, 20],
        name: auth.info.name || email.split("@").first,
        provider: auth.provider,
        uid: auth.uid
      )
      @user.save
    end

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
    else
      redirect_to new_user_registration_url, alert: "Could not sign in with #{provider}. #{@user.errors.full_messages.join(', ')}"
    end
  end
end
