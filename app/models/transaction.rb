# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :order

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true

  enum :status, {
    pending: "pending",
    succeeded: "succeeded",
    failed: "failed",
    refunded: "refunded",
    partially_refunded: "partially_refunded"
  }, default: :pending

  scope :successful, -> { where(status: :succeeded) }
  scope :failed, -> { where(status: :failed) }
  scope :refunded, -> { where(status: [ :refunded, :partially_refunded ]) }

  def refundable?
    succeeded? && refund_amount.to_d < amount
  end

  def fully_refunded?
    refund_amount.to_d >= amount
  end
end
