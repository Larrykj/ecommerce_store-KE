require "test_helper"

class StockNotificationTest < ActiveSupport::TestCase
  setup do
    @notification = stock_notifications(:one)
  end

  test "should be valid with valid attributes" do
    assert @notification.valid?
  end

  test "should require email" do
    @notification.email = nil
    assert_not @notification.valid?
  end

  test "should require valid email format" do
    @notification.email = "invalid"
    assert_not @notification.valid?
  end

  test "should enforce unique email per product" do
    dup = StockNotification.new(email: @notification.email, product: @notification.product)
    assert_not dup.valid?
  end

  test "belongs to product" do
    assert_kind_of Product, @notification.product
  end

  test "scope pending returns unnotified" do
    StockNotification.pending.each { |sn| assert_equal false, sn.notified }
  end
end
