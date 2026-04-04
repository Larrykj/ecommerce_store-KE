# frozen_string_literal: true

class ContactMessagesController < ApplicationController
  def new
    @contact_message = ContactMessage.new
    @contact_message.subject = params[:subject] if params[:subject].present?
    @contact_message.message = params[:message] if params[:message].present?

    if user_signed_in?
      @contact_message.name = current_user.name
      @contact_message.email = current_user.email
    end
  end

  def create
    @contact_message = ContactMessage.new(contact_message_params)
    @contact_message.user = current_user if user_signed_in?

    if @contact_message.save
      redirect_to contact_thank_you_path, notice: "Your message has been sent successfully! We'll get back to you soon."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :subject, :message)
  end
end
