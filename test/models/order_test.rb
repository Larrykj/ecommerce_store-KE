require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @order = orders(:one)
  end

  test "should be valid with valid attributes" do
    assert @order.valid?
  end

  test "should require name" do
    @order.name = nil
    assert_not @order.valid?
  end

  test "should require email" do
    @order.email = nil
    assert_not @order.valid?
  end

  test "should require valid email format" do
    @order.email = "invalid"
    assert_not @order.valid?
  end

  test "should require address" do
    @order.address = nil
    assert_not @order.valid?
  end

  test "should require phone" do
    @order.phone = nil
    assert_not @order.valid?
  end

  # ====== Associations ======
  test "belongs to user" do
    assert_equal users(:one), @order.user
  end

  test "has many order_items" do
    assert_respond_to @order, :order_items
  end

  test "has many transactions" do
    assert_respond_to @order, :transactions
  end

  test "has one return_request" do
    assert_respond_to @order, :return_request
  end

  # ====== Status Methods ======
  test "paid? returns true when payment_status is paid" do
    @order.payment_status = "paid"
    assert @order.paid?
  end

  test "paid? returns false when payment_status is unpaid" do
    @order.payment_status = "unpaid"
    assert_not @order.paid?
  end

  test "payment_pending? returns true when unpaid" do
    @order.payment_status = "unpaid"
    assert @order.payment_pending?
  end

  # ====== Order Tracking ======
  test "current_step_index returns valid index" do
    assert_kind_of Integer, @order.current_step_index
  end

  test "step_status returns valid status string" do
    status = @order.step_status("pending")
    assert_includes %w[active completed pending], status
  end

  test "percentage_complete returns integer between 0 and 100" do
    pct = @order.percentage_complete
    assert pct >= 0 && pct <= 100
  end

  test "ORDER_STEPS contains expected steps" do
    assert_includes Order::ORDER_STEPS, "pending"
    assert_includes Order::ORDER_STEPS, "processing"
    assert_includes Order::ORDER_STEPS, "shipped"
    assert_includes Order::ORDER_STEPS, "delivered"
  end
end
