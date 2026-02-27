class User < ApplicationRecord
  include Discard::Model

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2, :github ]

  # Encrypt sensitive user data (skip in test environment to avoid fixture issues)
  encrypts :name unless Rails.env.test?

  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :product_views, dependent: :destroy
  has_many :viewed_products, through: :product_views, source: :product
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlist_products, through: :wishlist_items, source: :product
  has_many :addresses, dependent: :destroy
  has_many :contact_messages, dependent: :nullify
  has_many :return_requests, dependent: :destroy
  has_many :stock_notifications, dependent: :destroy
  has_many :product_comparisons, dependent: :destroy

  validates :name, presence: true
  validates :password, length: { minimum: 12 }, if: -> { new_record? || password.present? }

  # Override Devise destroy to soft delete
  def destroy
    discard
  end

  # Prevent discarded users from logging in
  def active_for_authentication?
    super && !discarded?
  end

  # Provide a message for discarded users
  def inactive_message
    !discarded? ? super : :deleted_account
  end

  def recommended_products(limit = 4)
    recent_views = product_views.order(created_at: :desc).limit(10).includes(:product)
    recent_category_ids = recent_views.map { |pv| pv.product.category_id }.uniq.compact

    if recent_category_ids.any?
      # Recommend products from same categories, excluding ones recently viewed if desired,
      # but for now simple category match is good.
      Product.where(category_id: recent_category_ids)
             .where.not(id: viewed_products.select(:id))
             .order("RANDOM()")
             .limit(limit)
    else
      # Fallback: Recently added products
      Product.order(created_at: :desc).limit(limit)
    end
  end
end
# EOF
