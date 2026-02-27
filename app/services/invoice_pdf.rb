# frozen_string_literal: true

class InvoicePdf
  include Prawn::View

  def initialize(order)
    @order = order
    @document = Prawn::Document.new(page_size: "A4", margin: 40)
    build_invoice
  end

  private

  def build_invoice
    header
    customer_details
    order_items_table
    totals
    footer
  end

  def header
    text "INVOICE", size: 28, style: :bold, color: "4f46e5"
    move_down 5
    text "E-Commerce Store", size: 14, color: "64748b"
    text "Kenyatta Avenue, Nairobi, Kenya", size: 10, color: "94a3b8"
    text "support@ecomstore.co.ke", size: 10, color: "94a3b8"
    move_down 10
    stroke_horizontal_rule
    move_down 15

    # Invoice details
    text_box "Invoice ##{@order.id}", at: [0, cursor], size: 12, style: :bold
    text_box "Date: #{@order.created_at.strftime('%B %d, %Y')}", at: [300, cursor], size: 10, width: 200, align: :right
    move_down 20
  end

  def customer_details
    text "Bill To:", size: 10, color: "64748b"
    text @order.user&.name || @order.name || "Customer", size: 12, style: :bold
    text @order.user&.email || @order.email || "", size: 10
    if @order.respond_to?(:address) && @order.address.present?
      text @order.address, size: 10
    end
    move_down 20
  end

  def order_items_table
    items_data = [["Item", "SKU", "Qty", "Price", "Total"]]

    @order.order_items.each do |item|
      items_data << [
        item.variant&.product&.name || "Product",
        item.variant&.sku || "-",
        item.quantity.to_s,
        format_kes(item.price),
        format_kes(item.price * item.quantity)
      ]
    end

    table(items_data, width: bounds.width, cell_style: { size: 10, padding: [8, 10] }) do
      row(0).font_style = :bold
      row(0).background_color = "4f46e5"
      row(0).text_color = "ffffff"
      columns(2..4).align = :right
      cells.borders = [:bottom]
      cells.border_color = "e2e8f0"
    end
    move_down 15
  end

  def totals
    subtotal = @order.order_items.sum { |i| i.price * i.quantity }

    totals_data = []
    totals_data << ["Subtotal", format_kes(subtotal)]

    if @order.discount_amount.to_d > 0
      totals_data << ["Discount (#{@order.promo_code&.code})", "-#{format_kes(@order.discount_amount)}"]
    end

    if @order.shipping_cost.to_d > 0
      totals_data << ["Shipping (#{@order.shipping_method&.name || 'Standard'})", format_kes(@order.shipping_cost)]
    end

    if @order.tax_amount.to_d > 0
      totals_data << ["Tax (#{(@order.tax_rate.to_f * 100).to_i}% VAT)", format_kes(@order.tax_amount)]
    end

    totals_data << ["TOTAL", format_kes(@order.total_price)]

    totals_table = make_table(totals_data, cell_style: { size: 10, padding: [6, 10], borders: [] }, column_widths: [120, 100]) do
      columns(1).align = :right
      row(-1).font_style = :bold
      row(-1).size = 13
    end

    bounding_box([bounds.width - 230, cursor], width: 230) { totals_table.draw }
    move_down 15

    # Payment status
    status_color = @order.paid? ? "10b981" : "f59e0b"
    text "Payment Status: #{@order.paid? ? 'PAID' : 'UNPAID'}", size: 11, style: :bold, color: status_color
    move_down 20
  end

  def footer
    stroke_horizontal_rule
    move_down 10
    text "Thank you for your purchase!", size: 12, style: :bold, color: "1e293b", align: :center
    move_down 5
    text "For questions about this invoice, contact support@ecomstore.co.ke", size: 9, color: "94a3b8", align: :center
  end

  def format_kes(amount)
    "KSh #{amount.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}"
  end
end
