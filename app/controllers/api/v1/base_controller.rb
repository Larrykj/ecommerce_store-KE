# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      before_action :authenticate_api_user!

      private

      def authenticate_api_user!
        token = request.headers["Authorization"]&.split(" ")&.last
        @current_api_user = User.find_by(id: decode_token(token)) if token
        render json: { error: "Unauthorized" }, status: :unauthorized unless @current_api_user
      end

      def current_api_user
        @current_api_user
      end

      def decode_token(token)
        # Simple token-based auth using user ID encoding
        # In production, use JWT or similar
        Base64.decode64(token).to_i rescue nil
      end
    end
  end
end
