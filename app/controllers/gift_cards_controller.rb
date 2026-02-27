# frozen_string_literal: true

class GiftCardsController < ApplicationController
  before_action :authenticate_user!, except: [:check_balance]

  def index
    @gift_cards = GiftCard.where(purchased_by: current_user).or(GiftCard.where(redeemed_by: current_user)).order(created_at: :desc)
  end

  def new
    @gift_card = GiftCard.new(initial_value: 1000)
  end

  def create
    @gift_card = GiftCard.new(gift_card_params)
    @gift_card.purchased_by = current_user
    @gift_card.balance = @gift_card.initial_value

    if @gift_card.save
      redirect_to gift_cards_path, notice: "Gift card created! Code: #{@gift_card.code}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def check_balance
    @gift_card = GiftCard.find_by(code: params[:code]&.upcase&.strip)
  end

  private

  def gift_card_params
    params.require(:gift_card).permit(:initial_value, :recipient_email, :expires_at)
  end
end
