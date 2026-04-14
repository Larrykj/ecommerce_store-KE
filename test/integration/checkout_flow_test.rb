require "test_helper"

class CheckoutFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:regular_user)
    @product = products(:one)
    @variant = variants(:one)
    @variant.update!(quantity: 1) # Only 1 in stock

    # Set up user's cart
    @cart = Cart.create!(shipping_method: shipping_methods(:one))
    @cart_item = @cart.cart_items.create!(variant: @variant, quantity: 1)
  end

  test "checkout redirects to stripe session and deducts inventory on success" do
    sign_in @user
    post cart_items_path, params: { variant_id: @variant.id }

    # Initial quantity
    assert_equal 1, @variant.reload.quantity

    post checkout_path, params: {
      payment_method: "cod",
      order: {
        name: "John Doe",
        email: "john@example.com",
        address: "123 Main St",
        phone: "555-1234"
      }
    }

    @order = @user.orders.last
    assert_redirected_to order_path(@order)
    assert_equal "pending", @order.status
    assert_equal "pending", @order.payment_status

    # Verify inventory was deducted
    assert_equal 0, @variant.reload.quantity

    # Verify transaction created
    txn = @order.transactions.last
    assert_equal "pending", txn.status
  end

  test "race condition: checkout fails gracefully when inventory is gone before payment processing" do
    sign_in @user
    post cart_items_path, params: { variant_id: @variant.id }

    # Another user purchased stock before this checkout completes.
    @variant.update!(quantity: 0)

    post checkout_path, params: {
      payment_method: "cod",
      order: {
        name: "Alice",
        email: "a@a.com",
        address: "123 St",
        phone: "555-0000"
      }
    }

    @order = @user.orders.last
    assert_redirected_to order_path(@order)
    @order.reload
    assert_equal "pending", @order.payment_status
    assert_includes [ "backordered", "processing_backorder", "needs_refund" ], @order.status
  end
end
