require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @order = orders(:one)
  end

  test "should redirect index when not signed in" do
    get orders_url
    assert_redirected_to new_user_session_url
  end

  test "should get index when signed in" do
    sign_in @user
    get orders_url
    assert_response :success
  end

  test "should get show when signed in" do
    sign_in @user
    get order_url(@order)
    assert_response :success
  end

  test "should redirect show when not signed in" do
    get order_url(@order)
    assert_redirected_to new_user_session_url
  end
end
