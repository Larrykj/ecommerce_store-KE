class EmailSubscription < ApplicationRecord
  belongs_to :user, optional: true

  validates :email, presence: true
  validates :email, uniqueness: { scope: [ :subscribed_to ] }

  scope :subscribed, -> { where(subscribed: true) }
end
