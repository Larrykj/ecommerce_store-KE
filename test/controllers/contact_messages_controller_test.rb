require "test_helper"

class ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_contact_message_url
    assert_response :success
  end

  test "should create contact message with valid params" do
    assert_difference("ContactMessage.count") do
      post contact_messages_url, params: {
        contact_message: {
          name: "Test Sender",
          email: "sender@example.com",
          subject: "Test Subject",
          message: "This is a test message with enough characters to pass validation."
        }
      }
    end
    assert_redirected_to contact_thank_you_url
  end

  test "should not create contact message with invalid params" do
    assert_no_difference("ContactMessage.count") do
      post contact_messages_url, params: {
        contact_message: { name: "", email: "", subject: "", message: "" }
      }
    end
    assert_response :unprocessable_entity
  end
end
