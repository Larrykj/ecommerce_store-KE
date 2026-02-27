# frozen_string_literal: true

class Subscriber < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_create :generate_token

  scope :active, -> { where(status: "active") }

  def unsubscribe!
    update!(status: "unsubscribed")
  end

  def active?
    status == "active"
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
end
