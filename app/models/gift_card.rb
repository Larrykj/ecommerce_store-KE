# frozen_string_literal: true

class GiftCard < ApplicationRecord
  belongs_to :purchased_by, class_name: "User", optional: true
  belongs_to :redeemed_by, class_name: "User", optional: true

  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :initial_value, presence: true, numericality: { greater_than: 0 }
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, inclusion: { in: %w[active disabled expired] }, allow_nil: true

  before_validation :generate_code, on: :create

  scope :active, -> { where(status: "active") }
  scope :with_balance, -> { where("balance > 0") }

  def active?
    status == "active" && balance > 0 && (expires_at.nil? || expires_at >= Date.current)
  end

  def expired?
    expires_at.present? && expires_at < Date.current
  end

  def apply!(amount)
    with_lock do
      deduction = [ amount, balance ].min
      update!(balance: balance - deduction)
      deduction
    end
  end

  def formatted_balance
    "KSh #{balance.to_i}"
  end

  private

  def generate_code
    self.code ||= "GC-#{SecureRandom.alphanumeric(8).upcase}"
  end
end
