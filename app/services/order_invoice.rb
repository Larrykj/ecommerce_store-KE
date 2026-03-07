# frozen_string_literal: true

require "prawn"
require "prawn/table"

class OrderInvoice
  def initialize(order)
    @order = order
    @user = order.user
  end

  def generate
    pdf = Prawn::Document.new

    # Header
    pdf.font_size 24
    pdf.text "INVOICE", style: :bold
    pdf.move_down 10

    pdf.font_size 10
    pdf.text "Order ##{@order.id}"
    pdf.text "Date: #{@order.created_at.strftime('%B %d, %Y')}"
    pdf.text "Status: #{OrderService.status_label(@order.status)}"
    pdf.move_down 15

    # Customer info
    pdf.text "BILL TO:", style: :bold
    pdf.text @user.name
    pdf.text @user.email
    pdf.move_down 15

    # Items table
    items_data = [
      [ "Product", "SKU", "Qty", "Price", "Subtotal" ]
    ]

    @order.order_items.each do |item|
      items_data << [
        item.variant.product.name,
        item.variant.sku || "N/A",
        item.quantity.to_s,
        "KSh #{item.price.round(2)}",
        "KSh #{(item.price * item.quantity).round(2)}"
      ]
    end

    pdf.table(items_data, width: 500) do |table|
      table.header = true
      table.row(0).font_style = :bold
    end

    pdf.move_down 15

    # Totals
    pdf.text "Subtotal: KSh #{(@order.total_price - (@order.tax_amount || 0) - (@order.shipping_cost || 0)).round(2)}", align: :right
    pdf.text "Tax: KSh #{(@order.tax_amount || 0).round(2)}", align: :right
    pdf.text "Shipping: KSh #{(@order.shipping_cost || 0).round(2)}", align: :right
    pdf.font_size 12
    pdf.text "Total: KSh #{@order.total_price.round(2)}", style: :bold, align: :right

    pdf.move_down 20
    pdf.text "Thank you for your business!", align: :center, style: :italic

    pdf.render
  end
end
