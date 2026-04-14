# frozen_string_literal: true

module Api
  module V1
    class OrdersController < BaseController
      def index
        pagination = pagination_params
        limit = pagination[:limit]
        offset = pagination[:offset]

        orders = current_api_user.orders
                                .includes(order_items: { variant: :product }, shipping_method: [])
                                .order(created_at: :desc)
                                .limit(limit)
                                .offset(offset)

        total = current_api_user.orders.count
        render json: {
          orders: orders.map { |o| serialize_order(o, full: true) },
          total: total,
          meta: pagination_meta(total: total, limit: limit, offset: offset)
        }
      end

      def show
        order = current_api_user.orders.includes(order_items: { variant: :product }, shipping_method: [], gift_card: []).find(params[:id])
        render json: { order: serialize_order(order, full: true) }
      rescue ActiveRecord::RecordNotFound
        render_api_error(
          code: "order_not_found",
          message: "Order not found",
          status: :not_found
        )
      end

      private

      def serialize_order(order, full: false)
        data = {
          id: order.id,
          status: order.status,
          payment_status: order.payment_status,
          total_price: order.total_price.to_f,
          created_at: order.created_at
        }

        if full
          data[:items] = order.order_items.map { |i|
            {
              product: i.variant&.product&.name,
              variant: i.variant&.name,
              sku: i.variant&.sku,
              quantity: i.quantity,
              price: i.price.to_f,
              total: (i.price * i.quantity).to_f
            }
          }
          data[:shipping_method] = order.shipping_method&.name
          data[:discount] = order.discount_amount.to_f
          data[:tax] = order.tax_amount.to_f
          data[:shipping_cost] = order.shipping_cost.to_f
          data[:gift_card_amount] = order.gift_card_amount.to_f
        end

        data
      end
    end
  end
end
