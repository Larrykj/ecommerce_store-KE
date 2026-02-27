require "test_helper"

# CartItemsControllerTest - Integration tests for the CartItems controller
#
# This test class verifies cart item operations including:
# - Adding products to cart (create)
# - Updating item quantities (update)
# - Removing items from cart (destroy)
#
# Note: Cart is session-based, so we initialize cart by visiting a page first
#
# Author: Larrykj
# Last Updated: 2026-01-30
class CartItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @variant = variants(:one)
  end

  # Test: Verify adding a product to the cart
  # First visits products page to initialize session cart, then adds item
  test "should create cart_item" do
    # Initialize the cart session by visiting any page
    get products_url

    assert_difference("CartItem.count") do
      post cart_items_url, params: { variant_id: @variant.id }
    end

    assert_redirected_to cart_url
  end

  # Test: Verify updating cart item quantity
  test "should update cart_item" do
    # Initialize cart and add an item first
    get products_url
    post cart_items_url, params: { variant_id: @variant.id }

    # Get the cart item that was just created
    cart_item = CartItem.last

    # Update the quantity
    patch cart_item_url(cart_item), params: { quantity: 3 }
    assert_redirected_to cart_url
  end

  # Test: Verify removing an item from the cart
  test "should destroy cart_item" do
    # Initialize cart and add an item first
    get products_url
    post cart_items_url, params: { variant_id: @variant.id }

    cart_item = CartItem.last

    assert_difference("CartItem.count", -1) do
      delete cart_item_url(cart_item)
    end

    assert_redirected_to cart_url
  end
end
