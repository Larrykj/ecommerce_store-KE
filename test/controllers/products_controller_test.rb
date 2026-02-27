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

  # Test: Verify new product form is accessible
  test "should get new" do
    get new_product_url
    assert_response :success
  end

  # Test: Verify product creation with valid parameters
  # Includes category association for proper categorization
  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: {
        product: {
          name: "New Test Product",
          description: "This is a test product with a description that is long enough",
          price: 29.99,
          category_id: categories(:one).id
        }
      }
    end

    assert_redirected_to product_url(Product.last)
  end

  # Test: Verify edit form loads for existing product
  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  # Test: Verify product update with valid parameters
  test "should update product" do
    patch product_url(@product), params: {
      product: {
        name: "Updated Product",
        description: "Updated description that is long enough for validation",
        price: 39.99
      }
    }
    assert_redirected_to product_url(@product)
  end

  # Test: Verify product deletion (soft-delete via discard)
  # Creates a standalone product without cart_items to avoid FK constraint errors
  test "should destroy product" do
    # Create a standalone product without any cart_items referencing it
    product_to_delete = Product.create!(
      name: "Product To Delete",
      description: "This product will be deleted in the test",
      price: 10.00,
      category: categories(:one)
    )

    # discard is a soft-delete, so Product.count doesn't change
    delete product_url(product_to_delete)

    assert_redirected_to products_url
    assert product_to_delete.reload.discarded?
  end
end
