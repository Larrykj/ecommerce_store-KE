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

ActiveRecord::Schema[8.1].define(version: 2026_02_27_050105) do
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

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.datetime "created_at", null: false
    t.integer "quantity"
    t.datetime "updated_at", null: false
    t.bigint "variant_id", null: false
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["variant_id"], name: "index_cart_items_on_variant_id"
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "promo_code_id"
    t.bigint "shipping_method_id"
    t.datetime "updated_at", null: false
    t.index ["shipping_method_id"], name: "index_carts_on_shipping_method_id"
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
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

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
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
    t.datetime "created_at", null: false
    t.decimal "discount_amount"
    t.string "email"
    t.text "email_ciphertext"
    t.datetime "estimated_delivery_date"
    t.string "name"
    t.text "name_ciphertext"
    t.string "payment_status"
    t.string "phone"
    t.text "phone_ciphertext"
    t.bigint "promo_code_id"
    t.string "shipping_carrier"
    t.decimal "shipping_cost"
    t.bigint "shipping_method_id"
    t.string "status"
    t.string "stripe_checkout_session_id"
    t.decimal "tax_amount"
    t.decimal "tax_rate"
    t.decimal "total_price"
    t.string "tracking_number"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["promo_code_id"], name: "index_orders_on_promo_code_id"
    t.index ["shipping_method_id"], name: "index_orders_on_shipping_method_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_comparisons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.string "session_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["product_id"], name: "index_product_comparisons_on_product_id"
    t.index ["session_id", "product_id"], name: "index_product_comparisons_on_session_id_and_product_id", unique: true
    t.index ["user_id", "product_id"], name: "index_product_comparisons_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_product_comparisons_on_user_id"
  end

  create_table "product_views", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_product_views_on_product_id"
    t.index ["user_id"], name: "index_product_views_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "discarded_at"
    t.string "name"
    t.decimal "price"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["discarded_at"], name: "index_products_on_discarded_at"
    t.index ["name"], name: "index_products_on_name"
    t.index ["price"], name: "index_products_on_price"
  end

  create_table "promo_codes", force: :cascade do |t|
    t.boolean "active"
    t.string "code"
    t.datetime "created_at", null: false
    t.integer "current_uses"
    t.string "description"
    t.string "discount_type"
    t.decimal "discount_value"
    t.datetime "expires_at"
    t.integer "max_uses"
    t.decimal "min_order_amount"
    t.datetime "updated_at", null: false
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
    t.index ["product_id"], name: "index_reviews_on_product_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["user_id", "product_id"], name: "index_reviews_on_user_id_and_product_id", unique: true
    t.index ["user_id"], name: "index_reviews_on_user_id"
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
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.text "name_ciphertext"
    t.string "provider"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "uid"
    t.datetime "updated_at", null: false
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
    t.index ["product_id"], name: "index_variants_on_product_id"
    t.index ["sku"], name: "index_variants_on_sku", unique: true
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_wishlist_items_on_product_id"
    t.index ["user_id"], name: "index_wishlist_items_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "users"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "variants"
  add_foreign_key "carts", "shipping_methods"
  add_foreign_key "contact_messages", "users"
  add_foreign_key "gift_cards", "users", column: "purchased_by_id"
  add_foreign_key "gift_cards", "users", column: "redeemed_by_id"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "variants"
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
  add_foreign_key "variants", "products"
  add_foreign_key "wishlist_items", "products"
  add_foreign_key "wishlist_items", "users"
end
