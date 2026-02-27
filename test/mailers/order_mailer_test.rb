require "test_helper"

class OrderMailerTest < ActionMailer::TestCase
  setup do
    @order = orders(:two) # processing/paid order
  end

  test "confirmation" do
    mail = OrderMailer.with(order: @order).confirmation
    assert_equal "Order Confirmation - ##{@order.id}", mail.subject
    assert_equal [ @order.email ], mail.to
    assert_equal [ "no-reply@larrycommerce.com" ], mail.from
  end

  test "shipped" do
    mail = OrderMailer.with(order: @order).shipped
    assert_equal "Your order ##{@order.id} has shipped!", mail.subject
    assert_equal [ @order.email ], mail.to
    assert_equal [ "no-reply@larrycommerce.com" ], mail.from
  end
end
