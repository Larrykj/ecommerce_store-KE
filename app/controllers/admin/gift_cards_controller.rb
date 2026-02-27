# frozen_string_literal: true

class Admin::GiftCardsController < Admin::BaseController
  def index
    @gift_cards = GiftCard.order(created_at: :desc)
    @gift_cards = @gift_cards.where(status: params[:status]) if params[:status].present?
  end

  def new
    @gift_card = GiftCard.new(initial_value: 1000)
  end

  def create
    @gift_card = GiftCard.new(gift_card_admin_params)
    @gift_card.balance = @gift_card.initial_value

    if @gift_card.save
      redirect_to admin_gift_cards_path, notice: "Gift card created: #{@gift_card.code}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @gift_card = GiftCard.find(params[:id])
    @gift_card.update!(status: "disabled")
    redirect_to admin_gift_cards_path, notice: "Gift card disabled."
  end

  private

  def gift_card_admin_params
    params.require(:gift_card).permit(:initial_value, :recipient_email, :expires_at, :status)
  end
end
