# frozen_string_literal: true

module Api
  module V1
    class ProductsController < BaseController
      skip_before_action :authenticate_api_user!, only: [ :index, :show ]

      def index
        products = Product.kept
        products = products.where(category_id: params[:category_id]) if params[:category_id].present?
        products = products.search_by_term(params[:search]) if params[:search].present?
        products = products.order(created_at: :desc).limit(params[:limit] || 20).offset(params[:offset] || 0)

        render json: {
          products: products.map { |p| serialize_product(p) },
          total: Product.kept.count
        }
      end

      def show
        product = Product.kept.find(params[:id])
        render json: { product: serialize_product(product, full: true) }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Product not found" }, status: :not_found
      end

      private

      def serialize_product(product, full: false)
        data = {
          id: product.id,
          name: product.name,
          price: product.price.to_f,
          category: product.category&.name,
          in_stock: product.in_stock?,
          rating: product.average_rating.to_f,
          review_count: product.reviews.count,
          image_url: product.image.attached? ? url_for(product.image) : nil,
          created_at: product.created_at
        }

        if full
          data.merge!(
            description: product.description,
            variants: product.variants.map { |v|
              { id: v.id, name: v.name, sku: v.sku, price: v.price.to_f, quantity: v.quantity }
            },
            reviews: product.reviews.order(created_at: :desc).limit(10).map { |r|
              { id: r.id, rating: r.rating, title: r.title, content: r.content, user: r.user&.name, created_at: r.created_at }
            }
          )
        end

        data
      end
    end
  end
end
