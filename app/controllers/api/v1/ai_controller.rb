# frozen_string_literal: true

class Api::V1::AiController < Api::V1::BaseController
  skip_before_action :authenticate_api_user!, only: [ :chat, :recommendations ]
  before_action :set_optional_api_user, only: [ :recommendations ]

  def chat
    unless OpenAI.configuration.access_token.present?
      render json: { error: "OpenAI API Key is missing. Please configure it in environment variables." }, status: :internal_server_error
      return
    end

    message = params[:message].to_s.strip
    if message.blank?
      render json: { error: "Message cannot be blank." }, status: :unprocessable_entity
      return
    end

    if message.length > 1000
      render json: { error: "Message is too long. Maximum length is 1000 characters." }, status: :unprocessable_entity
      return
    end

    cache_key = "api/v1/ai/chat/#{Digest::SHA256.hexdigest(message.downcase)}"

    begin
      json_data = Rails.cache.fetch(cache_key, expires_in: 24.hours) do
        client = OpenAI::Client.new
        response = client.chat(
          parameters: {
            model: "gpt-4o-mini",
            messages: [
              { role: "system", content: "You are a helpful customer service assistant for E-Commerce KE. Answer politely and concisely." },
              { role: "user", content: message }
            ],
            temperature: 0.7
          }
        )

        reply = response.dig("choices", 0, "message", "content")
        { reply: reply }
      end

      render json: json_data
    rescue => e
      if e.message.include?("429")
        error_msg = "My AI brain has reached its rate limit or quota for the day! Please check your OpenAI billing dashboard or try again later. (Error 429)"
        Rails.cache.delete(cache_key)
        render json: { reply: error_msg }, status: :ok
      else
        render json: { error: "Failed to communicate with AI service. Please try again." }, status: :bad_gateway
      end
    end
  end

  def recommendations
    limit = [ [ params[:limit].to_i, 1 ].max, 12 ].min

    cache_key = if @current_api_user.present?
      "api/v1/ai/recommendations/#{@current_api_user.id}/#{limit}"
    else
      "api/v1/ai/recommendations/public/#{limit}"
    end

    recommendations = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      if @current_api_user.present?
        @current_api_user.recommended_products(limit).to_a
      else
        Product.kept
               .where("COALESCE(reviews_count, 0) > 0")
               .includes(:category, :variants)
               .with_attached_image
               .order(average_rating: :desc, reviews_count: :desc, created_at: :desc)
               .limit(limit).to_a
      end
    end

    recommendations = Product.kept.order(created_at: :desc).includes(:category, :variants).with_attached_image.limit(limit).to_a if recommendations.blank?

    render json: {
      recommendations: recommendations.map { |product|
        {
          id: product.id,
          title: product.name,
          price: product.price.to_f,
          average_rating: product.average_rating.to_f,
          reviews_count: product.reviews_count.to_i,
          product_path: Rails.application.routes.url_helpers.product_path(product),
          reason: recommendation_reason(product)
        }
      }
    }
  end

  private

  def set_optional_api_user
    token = request.headers["Authorization"]&.split(" ")&.last
    user_id = decode_token(token)
    @current_api_user = User.find_by(id: user_id) if user_id.present?
  end

  def recommendation_reason(product)
    return "Recommended based on your recent browsing patterns." if @current_api_user.present?

    if product.average_rating.to_f >= 4.5
      "Top-rated by shoppers."
    elsif product.reviews_count.to_i >= 10
      "Popular choice with strong customer feedback."
    else
      "New and noteworthy product for your catalog."
    end
  end
end
