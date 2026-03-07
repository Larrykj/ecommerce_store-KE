require "test_helper"

class ReturnRequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @order = orders(:one)
  end

  test "should redirect index when not signed in" do
    get return_requests_url
    assert_redirected_to new_user_session_url
  end

  test "should get index when signed in" do
    sign_in @user
    get return_requests_url
    assert_response :success
  end

  test "should get new when signed in" do
    sign_in @user
    get new_order_return_request_url(@order)
    assert_response :success
  end

  test "should create return request" do
    sign_in @user
    assert_difference("ReturnRequest.count") do
      post order_return_requests_url(@order), params: {
        return_request: {
          reason: "Defective/Damaged Item",
          description: "The product arrived with significant damage to the packaging and contents."
        }
      }
    end
    assert_redirected_to order_url(@order)
  end
end
