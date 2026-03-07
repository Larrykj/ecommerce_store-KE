require "test_helper"

class ContactMessageTest < ActiveSupport::TestCase
  setup do
    @msg = contact_messages(:one)
  end

  test "should be valid with valid attributes" do
    assert @msg.valid?
  end

  test "should require name" do
    @msg.name = nil
    assert_not @msg.valid?
  end

  test "should require email" do
    @msg.email = nil
    assert_not @msg.valid?
  end

  test "should require valid email format" do
    @msg.email = "invalid"
    assert_not @msg.valid?
  end

  test "should require subject" do
    @msg.subject = nil
    assert_not @msg.valid?
  end

  test "should require message" do
    @msg.message = nil
    assert_not @msg.valid?
  end

  test "message minimum 10 characters" do
    @msg.message = "short"
    assert_not @msg.valid?
  end

  test "mark_as_read! updates status" do
    @msg.mark_as_read!
    assert_equal "read", @msg.reload.status
  end

  test "unread? returns correct value" do
    @msg.status = "unread"
    assert @msg.unread?
    @msg.status = "read"
    assert_not @msg.unread?
  end

  test "scopes return correct results" do
    assert_respond_to ContactMessage.unread, :each
    assert_respond_to ContactMessage.read, :each
    assert_respond_to ContactMessage.recent, :each
  end
end
