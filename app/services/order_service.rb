# frozen_string_literal: true

class OrderService
  # Valid status transitions
  TRANSITIONS = {
    "pending" => [ "paid", "cancelled" ],
    "paid" => [ "processing", "cancelled" ],
    "processing" => [ "shipped", "cancelled" ],
    "shipped" => [ "delivered" ],
    "delivered" => [],
    "cancelled" => []
  }.freeze

  def self.valid_status_transition?(current_status, new_status)
    current_status = current_status.to_s
    new_status = new_status.to_s
    TRANSITIONS[current_status]&.include?(new_status) || false
  end

  def self.available_transitions(current_status)
    TRANSITIONS[current_status.to_s] || []
  end

  def self.status_label(status)
    case status
    when "pending"
      "Pending"
    when "paid"
      "Payment Confirmed"
    when "processing"
      "Processing"
    when "shipped"
      "Shipped"
    when "delivered"
      "Delivered"
    when "cancelled"
      "Cancelled"
    else
      status.humanize
    end
  end

  def self.status_color(status)
    case status
    when "pending"
      "warning"
    when "paid"
      "info"
    when "processing"
      "primary"
    when "shipped"
      "primary"
    when "delivered"
      "success"
    when "cancelled"
      "danger"
    else
      "secondary"
    end
  end
end
