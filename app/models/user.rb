# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model

  API_TOKEN_TTL = 30.days

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2, :github ]

  # NOTE: encrypts :name removed — Rails 8.1 Context API prevents setting
  # encryption keys at any boot stage without NoMethodError. Name stored as plain text.

  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :product_views, dependent: :destroy
  has_many :viewed_products, through: :product_views, source: :product
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlist_products, through: :wishlist_items, source: :product
  has_many :addresses, dependent: :destroy
  has_many :contact_messages, dependent: :nullify
  has_many :blog_posts, dependent: :destroy
  has_many :return_requests, dependent: :destroy
  has_many :stock_notifications, dependent: :destroy
  has_many :product_comparisons, dependent: :destroy
  has_many :loyalty_points, dependent: :destroy
  has_many :user_rewards, dependent: :destroy

  validates :name, presence: true

  # Enforce strong passwords (uppercase, lowercase, digit, special char, min 8 chars).
  # Only validates when password is being set (sign-up or password change), so existing users are not affected.
  validates :password, strong_password: true, if: :password_required?

  private

  def password_required?
    # Social-login users don't set passwords; skip validation for them
    return false if provider.present? && !password.present?
    !persisted? || password.present? || password_confirmation.present?
  end

  public

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
      # First, scope down to relevant categories (indexed query), then randomize in-memory
      candidate_ids = Product.where(category_id: recent_category_ids)
                             .where.not(id: viewed_products.select(:id))
                             .limit(limit * 3)
                             .pluck(:id)
      Product.where(id: candidate_ids.sample(limit))
    else
      # Fallback: Recently added products
      Product.order(created_at: :desc).limit(limit)
    end
  end

  # Signed API token for mobile/API usage.
  def api_token
    self.class.api_token_verifier.generate({ user_id: id }, purpose: "api_auth", expires_in: API_TOKEN_TTL)
  end

  def self.api_token_verifier
    Rails.application.message_verifier("api-auth-v1")
  end

  # ============ ADMIN AUTHORIZATION ============

  def admin?
    admin == true
  end

  def can_manage_products?
    admin?
  end

  def can_manage_categories?
    admin?
  end

  def can_manage_orders?
    admin?
  end

  def can_manage_users?
    admin?
  end

  def can_view_admin_dashboard?
    admin?
  end
end
# EOF
