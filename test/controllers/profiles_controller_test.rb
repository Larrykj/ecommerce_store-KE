require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
  end

  test "should redirect when not signed in" do
    get profile_url
    assert_redirected_to new_user_session_url
  end

  test "should get show when signed in" do
    sign_in @user
    get profile_url
    assert_response :success
  end
end
