# frozen_string_literal: true

require "net/http"
require "json"
require "base64"

# MPesa Daraja API integration via direct HTTP calls.
# No external gem dependency — uses Net::HTTP.
class MpesaPaymentService
  attr_reader :transaction_id, :error_message

  SANDBOX_BASE_URL = "https://sandbox.safaricom.co.ke"
  PRODUCTION_BASE_URL = "https://api.safaricom.co.ke"

  def initialize(order)
    @order = order
    @config = Rails.application.config.mpesa
    @transaction_id = nil
    @error_message = nil
  end

  def initiate_payment
    return fail_with("MPesa shortcode not configured") if @config[:shortcode].blank?
    return fail_with("MPesa passkey not configured") if @config[:passkey].blank?
    return fail_with("MPesa consumer key not configured") if @config[:consumer_key].blank?
    return fail_with("Order phone number missing") if @order.phone.blank?

    token = fetch_access_token
    return fail_with("Failed to obtain MPesa access token") unless token

    perform_stk_push(token)
  rescue StandardError => e
    Rails.logger.error("MPesa payment error: #{e.message}")
    fail_with(e.message)
  end

  private

  def base_url
    @config[:environment] == "production" ? PRODUCTION_BASE_URL : SANDBOX_BASE_URL
  end

  def fetch_access_token
    uri = URI("#{base_url}/oauth/v1/generate?grant_type=client_credentials")
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(@config[:consumer_key], @config[:consumer_secret])

    response = perform_request(uri, request)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    data["access_token"]
  rescue JSON::ParserError => e
    Rails.logger.error("MPesa token parse error: #{e.message}")
    nil
  end

  def perform_stk_push(token)
    timestamp = Time.current.strftime("%Y%m%d%H%M%S")
    password = Base64.strict_encode64("#{@config[:shortcode]}#{@config[:passkey]}#{timestamp}")
    phone = sanitize_phone(@order.phone)
    amount = @order.total_price.to_i
    amount = 1 if amount < 1 # Minimum 1 KES for sandbox testing

    uri = URI("#{base_url}/mpesa/stkpush/v1/processrequest")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{token}"
    request["Content-Type"] = "application/json"
    request.body = {
      BusinessShortCode: @config[:shortcode],
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: amount,
      PartyA: phone,
      PartyB: @config[:shortcode],
      PhoneNumber: phone,
      CallBackURL: callback_url,
      AccountReference: "Order-#{@order.id}",
      TransactionDesc: "Payment for Order ##{@order.id}"
    }.to_json

    response = perform_request(uri, request)
    return fail_with("STK Push request failed") unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    if data["ResponseCode"] == "0"
      @transaction_id = data["CheckoutRequestID"]
      Rails.logger.info("MPesa STK Push initiated: #{@transaction_id}")
      true
    else
      fail_with(data["ResponseDescription"] || data["errorMessage"] || "STK Push failed")
    end
  rescue JSON::ParserError => e
    Rails.logger.error("MPesa STK response parse error: #{e.message}")
    fail_with("Invalid response from MPesa")
  end

  def perform_request(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 15
    http.read_timeout = 30
    http.request(request)
  end

  def sanitize_phone(phone)
    # Convert Kenyan phone formats to international: 254XXXXXXXXX
    cleaned = phone.to_s.gsub(/[^0-9]/, "")
    if cleaned.start_with?("0")
      "254#{cleaned[1..]}"
    elsif cleaned.start_with?("254")
      cleaned
    elsif cleaned.start_with?("+254")
      cleaned.delete("+")
    else
      cleaned
    end
  end

  def callback_url
    if Rails.env.production?
      "https://ecommerce-store-ke.onrender.com/mpesa/callback"
    else
      "https://example.com/mpesa/callback" # Use ngrok URL for local testing
    end
  end

  def fail_with(message)
    @error_message = message
    Rails.logger.warn("MPesa payment failed: #{message}")
    false
  end
end
