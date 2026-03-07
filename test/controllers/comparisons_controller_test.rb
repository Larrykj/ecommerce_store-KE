require "test_helper"

class ComparisonsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @product = products(:one)
  end

  test "should get show without signing in" do
    get comparison_url
    assert_response :success
  end

  test "should get show when signed in" do
    sign_in @user
    get comparison_url
    assert_response :success
  end

  test "should add product to comparison when signed in" do
    sign_in @user
    # Clear existing comparisons first
    @user.product_comparisons.destroy_all
    post add_comparison_url, params: { product_id: @product.id }
    assert_response :redirect
  end

  test "should remove product from comparison" do
    sign_in @user
    delete remove_comparison_url, params: { product_id: @product.id }
    assert_response :redirect
  end

  test "should clear comparison" do
    sign_in @user
    delete clear_comparison_url
    assert_redirected_to comparison_url
  end
end
