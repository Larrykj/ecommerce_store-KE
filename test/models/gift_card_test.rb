require "test_helper"

class GiftCardTest < ActiveSupport::TestCase
  setup do
    @gift_card = gift_cards(:one)
  end

  test "should be valid with valid attributes" do
    assert @gift_card.valid?
  end

  test "should require code" do
    @gift_card.code = nil
    assert_not @gift_card.valid?
  end

  test "should require unique code" do
    dup = GiftCard.new(code: @gift_card.code, initial_value: 1000, balance: 1000, status: "active")
    assert_not dup.valid?
  end

  test "should require initial_value" do
    @gift_card.initial_value = nil
    assert_not @gift_card.valid?
  end

  test "initial_value must be greater than 0" do
    @gift_card.initial_value = 0
    assert_not @gift_card.valid?
  end

  test "balance must be >= 0" do
    @gift_card.balance = -1
    assert_not @gift_card.valid?
  end

  test "active? returns true for active card with balance" do
    assert @gift_card.active?
  end

  test "active? returns false for expired card" do
    expired = gift_cards(:expired)
    assert_not expired.active?
  end

  test "expired? returns true for past date" do
    expired = gift_cards(:expired)
    assert expired.expired?
  end

  test "expired? returns false when no expiry" do
    assert_not @gift_card.expired?
  end

  test "apply! deducts from balance" do
    initial = @gift_card.balance
    deducted = @gift_card.apply!(1000)
    assert_equal 1000, deducted
    assert_equal initial - 1000, @gift_card.reload.balance
  end

  test "apply! does not deduct more than balance" do
    deducted = @gift_card.apply!(@gift_card.balance + 5000)
    assert_equal 5000, deducted
    assert_equal 0, @gift_card.reload.balance
  end

  test "formatted_balance returns KSh format" do
    assert_match(/KSh/, @gift_card.formatted_balance)
  end

  test "generate_code auto-generates code on create" do
    gc = GiftCard.create!(initial_value: 500, balance: 500, status: "active")
    assert gc.code.present?
    assert gc.code.start_with?("GC-")
  end
end
