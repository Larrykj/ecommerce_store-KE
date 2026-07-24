# frozen_string_literal: true

class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :variants, through: :order_items
  has_many :products, through: :variants
  has_many :transactions, dependent: :destroy
  has_one :return_request, dependent: :destroy
  belongs_to :promo_code, optional: true
  belongs_to :shipping_method, optional: true
  belongs_to :gift_card, optional: true

  def paid?
    payment_status == "paid"
  end

  def payment_pending?
    payment_status.nil? || payment_status == "unpaid"
  end

  # NOTE: encrypts removed — Rails 8.1 Context API prevents encryption config at boot.
  # Fields (name, email, address, phone) stored as plain text in development.

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :address, presence: true
  validates :phone, presence: true

  # Updated enum syntax for Rails 7+
  enum :status, {
    pending: "pending",
    paid: "paid",
    processing: "processing",
    backordered: "backordered",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }, default: :pending

  # Raw sum of order items (before discounts, shipping, tax)
  def items_total
    order_items.sum { |item| item.price * item.quantity }
  end

  # Full calculated total including shipping + tax - discount - gift_card_amount
  def calculated_total
    items_total + (shipping_cost || 0) + (tax_amount || 0) - (discount_amount || 0) - (gift_card_amount || 0)
  end

  # Broadcast changes to the order for real-time updates
  after_update_commit -> { broadcast_replace_to self, target: "order_tracking_section", partial: "orders/tracking_details", locals: { order: self } }

  ORDER_STEPS = %w[pending paid processing shipped delivered].freeze

  def current_step_index
    ORDER_STEPS.index(status) || 0
  end

  def step_status(step)
    step_index = ORDER_STEPS.index(step)
    return "active" if step_index == current_step_index
    return "completed" if step_index < current_step_index
    "pending"
  end

  def percentage_complete
    return 100 if status == "delivered"
    return 100 if status == "cancelled"

    index = current_step_index
    total = ORDER_STEPS.size - 1
    (index.to_f / total * 100).to_i
  end
  # Refund helpers
  def total_refund_amount
    transactions.sum(:refund_amount)
  end

  def refunded?
<<<<<<< HEAD
<<<<<<< HEAD
    total_refund_amount > 0 && transactions.exists?(status: "refunded")
=======
    total_refund_amount > 0 && transactions.exists?(status: 'refunded')
>>>>>>> fba2b73 (fix: resolve refund display on customer side, UI/UX on checkout, and dark mode on product page)
=======
    total_refund_amount > 0 && transactions.exists?(status: "refunded")
>>>>>>> 427648f (style: autocorrect rubocop linting violations)
  end

  def partially_refunded?
    total_refund_amount > 0 && !refunded?
  end

  def refund_or_cancel_label
    if refunded?
<<<<<<< HEAD
<<<<<<< HEAD
      "Refunded"
    elsif partially_refunded?
      "Partially Refunded"
    elsif cancelled?
      "Cancelled"
=======
      'Refunded'
=======
      "Refunded"
>>>>>>> 427648f (style: autocorrect rubocop linting violations)
    elsif partially_refunded?
      "Partially Refunded"
    elsif cancelled?
<<<<<<< HEAD
      'Cancelled'
>>>>>>> fba2b73 (fix: resolve refund display on customer side, UI/UX on checkout, and dark mode on product page)
=======
      "Cancelled"
>>>>>>> 427648f (style: autocorrect rubocop linting violations)
    else
      status.titleize
    end
  end
end
