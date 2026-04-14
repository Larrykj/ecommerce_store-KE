class EmailTrigger < ApplicationRecord
  enum :event_type, { order_placed: "order_placed", order_delivered: "order_delivered", cart_abandoned: "cart_abandoned", product_viewed: "product_viewed", review_pending: "review_pending", birthday: "birthday" }, prefix: true

  has_one :email_campaign

  scope :active, -> { where(active: true) }
end

class EmailSubscription < ApplicationRecord
  belongs_to :user, optional: true

  validates :email, presence: true
  validates :email, uniqueness: { scope: [ :subscribed_to ] }

  scope :subscribed, -> { where(subscribed: true) }
end
