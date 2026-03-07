require "test_helper"

class AddressTest < ActiveSupport::TestCase
  setup do
    @address = addresses(:one)
  end

  test "should be valid with valid attributes" do
    assert @address.valid?
  end

  test "should require name" do
    @address.name = nil
    assert_not @address.valid?
  end

  test "should require address_line_1" do
    @address.address_line_1 = nil
    assert_not @address.valid?
  end

  test "should require city" do
    @address.city = nil
    assert_not @address.valid?
  end

  test "should require phone" do
    @address.phone = nil
    assert_not @address.valid?
  end

  test "full_address returns formatted string" do
    result = @address.full_address
    assert result.include?(@address.city)
    assert result.include?(@address.address_line_1)
  end

  test "display_name returns label and address" do
    result = @address.display_name
    assert result.include?(@address.city)
  end

  test "belongs to user" do
    assert_kind_of User, @address.user
  end

  test "scope ordered returns addresses" do
    results = Address.ordered
    assert_respond_to results, :each
  end
end
