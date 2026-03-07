require "test_helper"

class SubscribersControllerTest < ActionDispatch::IntegrationTest
  test "should create subscriber with valid email" do
    assert_difference("Subscriber.count") do
      post "/subscribers", params: {
        subscriber: { email: "newsubscriber@example.com" }
      }
    end
    assert_response :redirect
  end

  test "should not create subscriber with invalid email" do
    assert_no_difference("Subscriber.count") do
      post "/subscribers", params: {
        subscriber: { email: "" }
      }
    end
  end

  test "should not create duplicate subscriber" do
    sub = subscribers(:one)
    assert_no_difference("Subscriber.count") do
      post "/subscribers", params: {
        subscriber: { email: sub.email }
      }
    end
  end

  test "should unsubscribe with valid token" do
    sub = subscribers(:one)
    get "/unsubscribe/#{sub.token}"
    assert_response :success
    assert_equal "unsubscribed", sub.reload.status
  end
end
