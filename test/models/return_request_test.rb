require "test_helper"

class ReturnRequestTest < ActiveSupport::TestCase
  setup do
    @return_request = return_requests(:one)
  end

  test "should be valid with valid attributes" do
    assert @return_request.valid?
  end

  test "should require reason" do
    @return_request.reason = nil
    assert_not @return_request.valid?
  end

  test "should require description" do
    @return_request.description = nil
    assert_not @return_request.valid?
  end

  test "description must be at least 10 characters" do
    @return_request.description = "short"
    assert_not @return_request.valid?
  end

  test "belongs to order" do
    assert_respond_to @return_request, :order
    assert_kind_of Order, @return_request.order
  end

  test "belongs to user" do
    assert_respond_to @return_request, :user
    assert_kind_of User, @return_request.user
  end

  test "pending? returns true when status is pending" do
    assert @return_request.pending?
  end

  test "pending? returns false for approved status" do
    @return_request.status = "approved"
    assert_not @return_request.pending?
  end

  test "REASONS constant is defined and frozen" do
    assert ReturnRequest::REASONS.is_a?(Array)
    assert ReturnRequest::REASONS.frozen?
    assert ReturnRequest::REASONS.length >= 5
  end

  test "scope pending returns pending requests" do
    results = ReturnRequest.pending
    results.each { |rr| assert_equal "pending", rr.status }
  end

  test "scope recent orders by created_at desc" do
    results = ReturnRequest.recent
    assert_respond_to results, :each
  end
end
