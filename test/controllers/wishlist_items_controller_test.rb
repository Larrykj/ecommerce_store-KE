require "test_helper"

class WishlistItemsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @product = products(:one)
    sign_in @user
  end

  test "should get index" do
    get wishlist_items_url
    assert_response :success
  end

  test "should create wishlist_item" do
    assert_difference("WishlistItem.count") do
      post wishlist_items_url, params: { product_id: products(:two).id }
    end

    assert_redirected_to products_path
  end

  test "should destroy wishlist_item" do
    wishlist_item = WishlistItem.find_or_create_by!(user: @user, product: @product)
    assert_difference("WishlistItem.count", -1) do
      delete wishlist_item_url(wishlist_item)
    end

    assert_redirected_to products_path
  end

  test "should require authentication for index" do
    sign_out @user
    get wishlist_items_url
    assert_redirected_to new_user_session_path
  end

  test "should require authentication for create" do
    sign_out @user
    post wishlist_items_url, params: { product_id: @product.id }
    assert_redirected_to new_user_session_path
  end
end
