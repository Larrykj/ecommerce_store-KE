require "test_helper"

class SubscriberTest < ActiveSupport::TestCase
  setup do
    @subscriber = subscribers(:one)
  end

  test "should be valid with valid attributes" do
    assert @subscriber.valid?
  end

  test "should require email" do
    @subscriber.email = nil
    assert_not @subscriber.valid?
  end

  test "should require valid email format" do
    @subscriber.email = "invalid"
    assert_not @subscriber.valid?
  end

  test "should require unique email" do
    dup = Subscriber.new(email: @subscriber.email)
    assert_not dup.valid?
  end

  test "generate_token sets token on create" do
    sub = Subscriber.create!(email: "newtokentest@example.com")
    assert sub.token.present?
  end

  test "unsubscribe! changes status" do
    @subscriber.unsubscribe!
    assert_equal "unsubscribed", @subscriber.reload.status
  end

  test "active? returns true for active subscriber" do
    assert @subscriber.active?
  end

  test "active? returns false for unsubscribed" do
    unsub = subscribers(:two)
    assert_not unsub.active?
  end

  test "scope active returns only active subscribers" do
    Subscriber.active.each { |s| assert_equal "active", s.status }
  end
end
