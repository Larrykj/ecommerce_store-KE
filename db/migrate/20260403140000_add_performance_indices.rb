# frozen_string_literal: true

class AddPerformanceIndices < ActiveRecord::Migration[8.1]
  def change
    # Orders
    add_index :orders, :user_id unless index_exists?(:orders, :user_id)
    add_index :orders, :status unless index_exists?(:orders, :status)
    add_index :orders, :payment_status unless index_exists?(:orders, :payment_status)
    add_index :orders, :created_at unless index_exists?(:orders, :created_at)
    add_index :orders, :stripe_checkout_session_id, where: "stripe_checkout_session_id IS NOT NULL" unless index_exists?(:orders, :stripe_checkout_session_id)

    # Order items
    add_index :order_items, :variant_id unless index_exists?(:order_items, :variant_id)

    # Variants
    add_index :variants, :product_id unless index_exists?(:variants, :product_id)
    add_index :variants, :sku, unique: true unless index_exists?(:variants, :sku)

    # Reviews
    add_index :reviews, :product_id unless index_exists?(:reviews, :product_id)
    add_index :reviews, :user_id unless index_exists?(:reviews, :user_id)
    add_index :reviews, [:product_id, :user_id], unique: true unless index_exists?(:reviews, [:product_id, :user_id])

    # Wishlist items
    add_index :wishlist_items, :user_id unless index_exists?(:wishlist_items, :user_id)
    add_index :wishlist_items, :product_id unless index_exists?(:wishlist_items, :product_id)

    # Product views
    add_index :product_views, :user_id unless index_exists?(:product_views, :user_id)
    add_index :product_views, :product_id unless index_exists?(:product_views, :product_id)
    add_index :product_views, :created_at unless index_exists?(:product_views, :created_at)

    # Product comparisons
    add_index :product_comparisons, :product_id unless index_exists?(:product_comparisons, :product_id)
    add_index :product_comparisons, :user_id, where: "user_id IS NOT NULL" unless index_exists?(:product_comparisons, :user_id)
    add_index :product_comparisons, :session_id unless index_exists?(:product_comparisons, :session_id)

    # Stock notifications
    add_index :stock_notifications, :product_id unless index_exists?(:stock_notifications, :product_id)
    add_index :stock_notifications, :email unless index_exists?(:stock_notifications, :email)

    # Transactions
    add_index :transactions, :stripe_payment_intent_id, where: "stripe_payment_intent_id IS NOT NULL" unless index_exists?(:transactions, :stripe_payment_intent_id)
    add_index :transactions, :stripe_checkout_session_id, where: "stripe_checkout_session_id IS NOT NULL" unless index_exists?(:transactions, :stripe_checkout_session_id)

    # Subscribers
    add_index :subscribers, :email, unique: true unless index_exists?(:subscribers, :email)
    add_index :subscribers, :token, unique: true unless index_exists?(:subscribers, :token)

    # Contact messages
    add_index :contact_messages, :status unless index_exists?(:contact_messages, :status)

    # Gift cards
    add_index :gift_cards, :code unless index_exists?(:gift_cards, :code)
    add_index :gift_cards, :status unless index_exists?(:gift_cards, :status)

    # Promo codes
    add_index :promo_codes, :code unless index_exists?(:promo_codes, :code)
    add_index :promo_codes, :active unless index_exists?(:promo_codes, :active)

    # Addresses
    add_index :addresses, :user_id unless index_exists?(:addresses, :user_id)
    add_index :addresses, [:user_id, :default] unless index_exists?(:addresses, [:user_id, :default])

    # Return requests
    add_index :return_requests, :status unless index_exists?(:return_requests, :status)
    add_index :return_requests, :user_id unless index_exists?(:return_requests, :user_id)
    add_index :return_requests, :order_id unless index_exists?(:return_requests, :order_id)
  end
end
