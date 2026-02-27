# frozen_string_literal: true

class Admin::ContactMessagesController < Admin::BaseController
  before_action :set_message, only: [ :show, :destroy, :mark_read ]

  def index
    @messages = ContactMessage.recent
    @unread_count = ContactMessage.unread.count
  end

  def show
    @message.mark_as_read! if @message.unread?
  end

  def destroy
    @message.destroy
    redirect_to admin_contact_messages_path, notice: "Message deleted."
  end

  def mark_read
    @message.mark_as_read!
    redirect_to admin_contact_messages_path, notice: "Message marked as read."
  end

  private

  def set_message
    @message = ContactMessage.find(params[:id])
  end
end
