require "test_helper"

class UserRegistrationFlowTest < ActionDispatch::IntegrationTest
  test "user can register and receive promotional tier" do
    get new_user_registration_path
    assert_response :success

    post user_registration_path, params: {
      user: {
        name: "Test User",
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_redirected_to root_path
    follow_redirect!
    assert_select "div.alert"

    user = User.find_by(email: "test@example.com")
    assert_not_nil user
    assert_equal "Test User", user.name
  end
end
