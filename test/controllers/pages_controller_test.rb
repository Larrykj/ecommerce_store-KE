require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get about" do
    get about_url
    assert_response :success
  end

  test "should get faq" do
    get faq_url
    assert_response :success
  end

  test "should get privacy_policy" do
    get privacy_policy_url
    assert_response :success
  end

  test "should get terms" do
    get terms_url
    assert_response :success
  end

  test "should get return_policy" do
    get return_policy_url
    assert_response :success
  end

  test "should get shipping_info" do
    get shipping_info_url
    assert_response :success
  end
end
