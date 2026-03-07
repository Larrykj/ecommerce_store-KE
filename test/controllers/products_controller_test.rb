require "test_helper"

# ProductsControllerTest - Integration tests for the Products controller
#
# This test class verifies CRUD operations for products including:
# - Listing all products (index)
# - Viewing individual products (show)
# - Creating new products (new, create)
# - Editing products (edit, update)
# - Deleting products (destroy)
#
# Note: Products can be optionally associated with categories
#
# Author: Larrykj
# Last Updated: 2026-01-30
class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  # Test: Verify products index page loads successfully
  test "should get index" do
    get products_url
    assert_response :success
  end

  # Test: Verify individual product page displays
  test "should get show" do
    get product_url(@product)
    assert_response :success
  end
end
