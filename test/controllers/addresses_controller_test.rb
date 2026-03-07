require "test_helper"

class AddressesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    @address = addresses(:one)
  end

  test "should redirect index when not signed in" do
    get addresses_url
    assert_redirected_to new_user_session_url
  end

  test "should get index when signed in" do
    sign_in @user
    get addresses_url
    assert_response :success
  end

  test "should get new when signed in" do
    sign_in @user
    get new_address_url
    assert_response :success
  end

  test "should create address" do
    sign_in @user
    assert_difference("Address.count") do
      post addresses_url, params: {
        address: {
          label: "Work",
          name: "Test User",
          phone: "+254711111111",
          address_line_1: "789 New Street",
          city: "Kisumu",
          country: "Kenya"
        }
      }
    end
    assert_redirected_to profile_url
  end

  test "should get edit when signed in" do
    sign_in @user
    get edit_address_url(@address)
    assert_response :success
  end

  test "should update address" do
    sign_in @user
    patch address_url(@address), params: {
      address: { city: "Updated City" }
    }
    assert_redirected_to profile_url
  end

  test "should destroy address" do
    sign_in @user
    assert_difference("Address.count", -1) do
      delete address_url(@address)
    end
    assert_redirected_to profile_url
  end

  test "should set default address" do
    sign_in @user
    patch set_default_address_url(@address)
    assert_redirected_to profile_url
  end
end
