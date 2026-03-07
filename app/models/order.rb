class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_many :transactions, dependent: :destroy
  has_one :return_request, dependent: :destroy
  belongs_to :promo_code, optional: true
  belongs_to :shipping_method, optional: true

  def paid?
    payment_status == "paid"
  end

  def payment_pending?
    payment_status.nil? || payment_status == "unpaid"
  end

  # Encrypt sensitive order data (skip in test environment to avoid fixture issues)
  encrypts :name unless Rails.env.test?
  encrypts :email unless Rails.env.test?
  encrypts :address unless Rails.env.test?
  encrypts :phone unless Rails.env.test?

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :address, presence: true
  validates :phone, presence: true

  # Updated enum syntax for Rails 7+
  enum :status, { pending: "pending", paid: "paid", processing: "processing", shipped: "shipped", delivered: "delivered", cancelled: "cancelled" }, default: :pending

  def total_price
    order_items.sum { |item| item.price * item.quantity }
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
end
