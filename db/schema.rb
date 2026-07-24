# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_07_111909) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_line_1", null: false
    t.string "address_line_2"
    t.string "city", null: false
    t.string "country", default: "Kenya"
    t.datetime "created_at", null: false
    t.boolean "default", default: false
    t.string "label", default: "Home"
    t.string "name", null: false
    t.string "phone"
    t.string "postal_code"
    t.string "state"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "default"], name: "index_addresses_on_user_id_and_default"
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "blog_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.integer "position", default: 0
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_blog_categories_on_slug", unique: true
  end

  create_table "blog_comments", force: :cascade do |t|
    t.boolean "approved", default: true
    t.text "content"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.bigint "parent_id"
    t.bigint "post_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["approved"], name: "index_blog_comments_on_approved"
    t.index ["parent_id"], name: "index_blog_comments_on_parent_id"
    t.index ["post_id"], name: "index_blog_comments_on_post_id"
    t.index ["user_id"], name: "index_blog_comments_on_user_id"
  end

  create_table "blog_posts", force: :cascade do |t|
    t.bigint "category_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.string "featured_image"
    t.text "meta_description"
    t.string "meta_title"
    t.boolean "published", default: false
    t.datetime "published_at"
    t.string "slug"
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "views_count", default: 0
    t.index ["category_id"], name: "index_blog_posts_on_category_id"
    t.index ["published"], name: "index_blog_posts_on_published"
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
    t.index ["user_id"], name: "index_blog_posts_on_user_id"
  end

  create_table "bundle_items", force: :cascade do |t|
    t.bigint "bundle_id", null: false
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", default: 1
    t.datetime "updated_at", null: false
    t.index ["bundle_id", "product_id"], name: "index_bundle_items_on_bundle_id_and_product_id", unique: true
    t.index ["bundle_id"], name: "index_bundle_items_on_bundle_id"
    t.index ["product_id"], name: "index_bundle_items_on_product_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.datetime "created_at", null: false
    t.integer "quantity", default: 1
    t.datetime "updated_at", null: false
    t.bigint "variant_id", null: false
    t.index ["cart_id", "variant_id"], name: "index_cart_items_on_cart_id_and_variant_id", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["variant_id"], name: "index_cart_items_on_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "gift_card_id"
    t.integer "promo_code_id"
    t.bigint "shipping_method_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["gift_card_id"], name: "index_carts_on_gift_card_id"
    t.index ["promo_code_id"], name: "index_carts_on_promo_code_id"
    t.index ["shipping_method_id"], name: "index_carts_on_shipping_method_id"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.text "meta_description"
    t.string "meta_title"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["discarded_at"], name: "index_categories_on_discarded_at"
    t.index ["name"], name: "index_categories_on_name"
  end

  create_table "contact_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.string "name", null: false
    t.string "status", default: "unread"
    t.string "subject", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["status"], name: "index_contact_messages_on_status"
    t.index ["user_id"], name: "index_contact_messages_on_user_id"
  end

  create_table "email_campaigns", force: :cascade do |t|
    t.boolean "active", default: true
    t.text "body"
    t.string "campaign_type"
    t.integer "clicked_count"
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "opened_count"
    t.integer "recipients_count"
    t.datetime "scheduled_at"
    t.datetime "sent_at"
    t.text "subject"
    t.datetime "updated_at", null: false
    t.index ["campaign_type"], name: "index_email_campaigns_on_campaign_type"
  end

  create_table "email_subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.boolean "subscribed", default: true
    t.string "subscribed_to"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["email", "subscribed_to"], name: "index_email_subscriptions_on_email_and_subscribed_to", unique: true
    t.index ["user_id"], name: "index_email_subscriptions_on_user_id"
  end

  create_table "email_triggers", force: :cascade do |t|
    t.string "action"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.integer "delay_days"
    t.string "event_type"
    t.datetime "updated_at", null: false
  end

  create_table "flash_sale_products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "flash_sale_id", null: false
    t.integer "max_quantity"
    t.bigint "product_id", null: false
    t.integer "sold_count", default: 0
    t.decimal "special_price"
    t.datetime "updated_at", null: false
    t.index ["flash_sale_id", "product_id"], name: "index_flash_sale_products_on_flash_sale_id_and_product_id", unique: true
    t.index ["flash_sale_id"], name: "index_flash_sale_products_on_flash_sale_id"
    t.index ["product_id"], name: "index_flash_sale_products_on_product_id"
  end

  create_table "flash_sales", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.decimal "discount_percent"
    t.datetime "end_time"
    t.string "name"
    t.datetime "start_time"
    t.datetime "updated_at", null: false
    t.index ["active", "start_time", "end_time"], name: "index_flash_sales_on_active_and_times"
  end

  create_table "gift_cards", force: :cascade do |t|
    t.decimal "balance", precision: 10, scale: 2, null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.date "expires_at"
    t.decimal "initial_value", precision: 10, scale: 2, null: false
    t.bigint "purchased_by_id"
    t.string "recipient_email"
    t.bigint "redeemed_by_id"
    t.string "status", default: "active"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_gift_cards_on_code", unique: true
    t.index ["purchased_by_id"], name: "index_gift_cards_on_purchased_by_id"
    t.index ["redeemed_by_id"], name: "index_gift_cards_on_redeemed_by_id"
    t.index ["status"], name: "index_gift_cards_on_status"
  end

  create_table "loyalty_points", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id"
    t.integer "points"
    t.string "reason"
    t.boolean "redeemed", default: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["order_id"], name: "index_loyalty_points_on_order_id"
    t.index ["user_id"], name: "index_loyalty_points_on_user_id"
  end

  create_table "loyalty_programs", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.integer "minimum_redemption", default: 100
    t.string "name"
    t.decimal "points_per_dollar", default: "1.0"
    t.datetime "updated_at", null: false
  end

  create_table "loyalty_rewards", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.string "description"
    t.decimal "discount_amount"
    t.decimal "discount_percent"
    t.bigint "loyalty_program_id", null: false
    t.integer "max_redemptions"
    t.string "name"
    t.integer "points_required"
    t.integer "redemption_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["loyalty_program_id"], name: "index_loyalty_rewards_on_loyalty_program_id"
  end

  create_table "loyalty_tiers", force: :cascade do |t|
    t.string "badge_color"
    t.datetime "created_at", null: false
    t.decimal "discount_percent", default: "0.0"
    t.bigint "loyalty_program_id", null: false
    t.integer "min_points"
    t.string "name"
    t.decimal "points_multiplier", default: "1.0"
    t.datetime "updated_at", null: false
    t.index ["loyalty_program_id"], name: "index_loyalty_tiers_on_loyalty_program_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "order_id", null: false
    t.decimal "price"
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.bigint "variant_id", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["variant_id"], name: "index_order_items_on_variant_id"
  end

  create_table "orders", force: :cascade do |t|
    t.text "address"
    t.text "address_ciphertext"
    t.bigint "address_id"
    t.datetime "created_at", null: false
    t.decimal "discount_amount"
    t.string "email"
    t.text "email_ciphertext"
    t.datetime "estimated_delivery_date"
    t.datetime "fulfillment_processed_at"
    t.decimal "gift_card_amount"
    t.bigint "gift_card_id"
    t.string "name"
    t.text "name_ciphertext"
    t.text "notes"
    t.string "payment_method", default: "manual_confirmation", null: false
    t.string "payment_provider"
    t.string "payment_reference"
    t.string "payment_status"
    t.string "phone"
    t.text "phone_ciphertext"
    t.bigint "promo_code_id"
    t.string "shipping_carrier"
    t.decimal "shipping_cost"
    t.bigint "shipping_method_id"
    t.string "status", default: "pending"
    t.string "stripe_checkout_session_id"
    t.decimal "tax_amount"
    t.decimal "tax_rate"
    t.decimal "total_price"
    t.string "tracking_number"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["gift_card_id"], name: "index_orders_on_gift_card_id"
    t.index ["payment_status"], name: "index_orders_on_payment_status"
    t.index ["promo_code_id"], name: "index_orders_on_promo_code_id"
    t.index ["shipping_method_id"], name: "index_orders_on_shipping_method_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["stripe_checkout_session_id"], name: "index_orders_on_stripe_checkout_session_id", where: "(stripe_checkout_session_id IS NOT NULL)"
    t.index ["user_id", "created_at"], name: "index_orders_on_user_id_and_created_at"
    t.index ["user_id", "status"], name: "index_orders_on_user_id_and_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_bundles", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.text "description"
    t.decimal "discount_percent"
    t.integer "max_quantity"
    t.string "name"
    t.decimal "original_price"
    t.decimal "price"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_product_bundles_on_slug", unique: true
  end

  create_table "product_comparisons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.string "session_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["product_id"], name: "index_product_comparisons_on_product_id"
    t.index ["session_id", "product_id"], name: "index_product_comparisons_on_session_id_and_product_id", unique: true
    t.index ["session_id"], name: "index_product_comparisons_on_session_id"
    t.index ["user_id", "product_id"], name: "index_product_comparisons_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_product_comparisons_on_user_id"
  end

  create_table "product_views", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_product_views_on_created_at"
    t.index ["product_id"], name: "index_product_views_on_product_id"
    t.index ["user_id"], name: "index_product_views_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.text "meta_description"
    t.string "meta_title"
    t.string "name"
    t.decimal "price", precision: 10, scale: 2
    t.integer "reviews_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["average_rating"], name: "index_products_on_average_rating"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["created_at"], name: "index_products_on_created_at"
    t.index ["discarded_at"], name: "index_products_on_discarded_at"
    t.index ["name"], name: "index_products_on_name"
    t.index ["price"], name: "index_products_on_price"
    t.index ["reviews_count"], name: "index_products_on_reviews_count"
  end

  create_table "promo_codes", force: :cascade do |t|
    t.boolean "active"
    t.string "code"
    t.datetime "created_at", null: false
    t.integer "current_uses"
    t.string "description"
    t.string "discount_type"
    t.decimal "discount_value"
    t.boolean "display_on_storefront"
    t.datetime "expires_at"
    t.integer "max_uses"
    t.decimal "min_order_amount"
    t.string "promo_message"
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_promo_codes_on_active"
    t.index ["code"], name: "index_promo_codes_on_code", unique: true
    t.index ["current_uses"], name: "index_promo_codes_on_current_uses"
  end

  create_table "return_requests", force: :cascade do |t|
    t.text "admin_notes"
    t.datetime "created_at", null: false
    t.text "description"
    t.bigint "order_id", null: false
    t.string "reason", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["order_id"], name: "index_return_requests_on_order_id"
    t.index ["status"], name: "index_return_requests_on_status"
    t.index ["user_id"], name: "index_return_requests_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.integer "helpful_count", default: 0
    t.bigint "product_id", null: false
    t.integer "rating", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["created_at"], name: "index_reviews_on_created_at"
    t.index ["product_id", "user_id"], name: "index_reviews_on_product_id_and_user_id", unique: true
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["user_id", "product_id"], name: "index_reviews_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "seo_settings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "extra_tags"
    t.text "meta_description"
    t.string "meta_title"
    t.string "page_type"
    t.datetime "updated_at", null: false
    t.index ["page_type"], name: "index_seo_settings_on_page_type", unique: true
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.boolean "active"
    t.decimal "base_rate"
    t.datetime "created_at", null: false
    t.integer "estimated_days"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "stock_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "notified", default: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["email"], name: "index_stock_notifications_on_email"
    t.index ["product_id", "email"], name: "index_stock_notifications_on_product_id_and_email", unique: true
    t.index ["product_id"], name: "index_stock_notifications_on_product_id"
    t.index ["user_id"], name: "index_stock_notifications_on_user_id"
  end

  create_table "subscribers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name"
    t.string "status", default: "active"
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_subscribers_on_email", unique: true
    t.index ["token"], name: "index_subscribers_on_token", unique: true
  end

  create_table "transactions", force: :cascade do |t|
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.string "currency"
    t.text "error_message"
    t.bigint "order_id", null: false
    t.string "payment_method"
    t.decimal "refund_amount"
    t.datetime "refunded_at"
    t.string "status"
    t.string "stripe_checkout_session_id"
    t.string "stripe_payment_intent_id"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_transactions_on_order_id"
    t.index ["stripe_checkout_session_id"], name: "index_transactions_on_stripe_checkout_session_id", where: "(stripe_checkout_session_id IS NOT NULL)"
    t.index ["stripe_payment_intent_id"], name: "index_transactions_on_stripe_payment_intent_id", where: "(stripe_payment_intent_id IS NOT NULL)"
  end

  create_table "user_rewards", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "loyalty_reward_id", null: false
    t.bigint "order_id"
    t.datetime "updated_at", null: false
    t.boolean "used", default: false
    t.bigint "user_id", null: false
    t.index ["loyalty_reward_id"], name: "index_user_rewards_on_loyalty_reward_id"
    t.index ["order_id"], name: "index_user_rewards_on_order_id"
    t.index ["user_id"], name: "index_user_rewards_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "current_tier_id"
    t.datetime "discarded_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.text "name_ciphertext"
    t.string "phone"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["current_tier_id"], name: "index_users_on_current_tier_id"
    t.index ["discarded_at"], name: "index_users_on_discarded_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "variants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "lock_version"
    t.string "name"
    t.decimal "price"
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.string "sku"
    t.datetime "updated_at", null: false
    t.index ["product_id", "quantity"], name: "index_variants_on_product_id_and_quantity"
    t.index ["product_id"], name: "index_variants_on_product_id"
    t.index ["quantity"], name: "index_variants_on_quantity"
    t.index ["sku"], name: "index_variants_on_sku", unique: true
    t.index ["updated_at"], name: "index_variants_on_updated_at"
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_wishlist_items_on_product_id"
    t.index ["user_id", "product_id"], name: "index_wishlist_items_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_wishlist_items_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "blog_comments", "blog_comments", column: "parent_id"
  add_foreign_key "blog_comments", "blog_posts", column: "post_id"
  add_foreign_key "blog_comments", "users"
  add_foreign_key "blog_posts", "blog_categories", column: "category_id"
  add_foreign_key "blog_posts", "users"
  add_foreign_key "bundle_items", "product_bundles", column: "bundle_id"
  add_foreign_key "bundle_items", "products"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "variants"
  add_foreign_key "carts", "gift_cards"
  add_foreign_key "carts", "shipping_methods"
  add_foreign_key "contact_messages", "users"
  add_foreign_key "email_subscriptions", "users"
  add_foreign_key "flash_sale_products", "flash_sales"
  add_foreign_key "flash_sale_products", "products"
  add_foreign_key "gift_cards", "users", column: "purchased_by_id"
  add_foreign_key "gift_cards", "users", column: "redeemed_by_id"
  add_foreign_key "loyalty_points", "orders"
  add_foreign_key "loyalty_points", "users"
  add_foreign_key "loyalty_rewards", "loyalty_programs"
  add_foreign_key "loyalty_tiers", "loyalty_programs"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "variants"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "gift_cards"
  add_foreign_key "orders", "promo_codes"
  add_foreign_key "orders", "shipping_methods"
  add_foreign_key "orders", "users"
  add_foreign_key "product_comparisons", "products"
  add_foreign_key "product_comparisons", "users"
  add_foreign_key "product_views", "products"
  add_foreign_key "product_views", "users"
  add_foreign_key "products", "categories"
  add_foreign_key "return_requests", "orders"
  add_foreign_key "return_requests", "users"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
  add_foreign_key "stock_notifications", "products"
  add_foreign_key "stock_notifications", "users"
  add_foreign_key "transactions", "orders"
  add_foreign_key "user_rewards", "loyalty_rewards"
  add_foreign_key "user_rewards", "orders"
  add_foreign_key "user_rewards", "users"
  add_foreign_key "variants", "products"
  add_foreign_key "wishlist_items", "products"
  add_foreign_key "wishlist_items", "users"
end
