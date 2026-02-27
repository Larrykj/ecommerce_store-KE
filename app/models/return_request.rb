# frozen_string_literal: true

class ReturnRequest < ApplicationRecord
  belongs_to :order
  belongs_to :user

  validates :reason, presence: true
  validates :description, presence: true, length: { minimum: 10 }

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :recent, -> { order(created_at: :desc) }

  REASONS = [
    "Defective/Damaged Item",
    "Wrong Item Received",
    "Item Not as Described",
    "Changed My Mind",
    "Size/Fit Issue",
    "Quality Not as Expected",
    "Other"
  ].freeze

  def pending?
    status == "pending"
  end

  def can_be_requested?(user)
    order.user == user && order.status == "delivered" && !ReturnRequest.exists?(order: order)
  end
end
