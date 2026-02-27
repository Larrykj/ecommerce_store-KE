# frozen_string_literal: true

class ContactMessage < ApplicationRecord
  belongs_to :user, optional: true

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true
  validates :message, presence: true, length: { minimum: 10 }

  scope :unread, -> { where(status: "unread") }
  scope :read, -> { where(status: "read") }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update!(status: "read")
  end

  def unread?
    status == "unread"
  end
end
