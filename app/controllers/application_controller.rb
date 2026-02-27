class ApplicationController < ActionController::Base
  require_relative "../services/exchange_rate_service"
  include Pagy::Method

  before_action :initialize_cart

  before_action :set_locale

  before_action :set_currency

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_currency, :format_price

  private

  def initialize_cart
    @cart = Cart.find_by(id: session[:cart_id])

    if @cart.nil?
      @cart = Cart.create
      session[:cart_id] = @cart.id
    end
  end

  def set_locale
    # Forces English unless explicitly requested via URL (fixes stuck session issue)
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    I18n.locale != I18n.default_locale ? { locale: I18n.locale } : {}
  end

  def set_currency
    if params[:currency]
      session[:currency] = params[:currency]
    end
  end

  def current_currency
    session[:currency] || "KES"
  end

  # Expanded conversion with real-time rates via ExchangeRateService
  def format_price(price_in_kes)
    return "0" unless price_in_kes
    currency = current_currency
    rate = ExchangeRateService.get_rate(currency)
    if rate.nil?
      rate = case currency
      when "USD" then 0.0075
      when "EUR" then 0.0068
      when "GBP" then 0.0058
      when "JPY" then 1.10
      when "CNY" then 0.054
      when "INR" then 0.62
      when "CAD" then 0.010
      when "AUD" then 0.011
      when "ZAR" then 0.14
      else 1
      end
    end
    converted_price = price_in_kes * rate
    case currency
    when "USD" then "$#{'%.2f' % converted_price}"
    when "EUR" then "€#{'%.2f' % converted_price}"
    when "GBP" then "£#{'%.2f' % converted_price}"
    when "JPY" then "¥#{'%.0f' % converted_price}"
    when "CNY" then "¥#{'%.2f' % converted_price}"
    when "INR" then "₹#{'%.2f' % converted_price}"
    when "CAD" then "C$#{'%.2f' % converted_price}"
    when "AUD" then "A$#{'%.2f' % converted_price}"
    when "ZAR" then "R#{'%.2f' % converted_price}"
    else "KSh #{'%.2f' % converted_price}"
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end
end
