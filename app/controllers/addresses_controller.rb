# frozen_string_literal: true

class AddressesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_address, only: [:edit, :update, :destroy, :set_default]

  def index
    @addresses = current_user.addresses.ordered
  end

  def new
    @address = current_user.addresses.build(country: "Kenya")
  end

  def create
    @address = current_user.addresses.build(address_params)

    if @address.save
      redirect_to profile_path, notice: "Address saved successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @address.update(address_params)
      redirect_to profile_path, notice: "Address updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address.destroy
    redirect_to profile_path, notice: "Address removed."
  end

  def set_default
    @address.update!(default: true)
    redirect_to profile_path, notice: "Default address updated."
  end

  private

  def set_address
    @address = current_user.addresses.find(params[:id])
  end

  def address_params
    params.require(:address).permit(:label, :name, :phone, :address_line_1, :address_line_2, :city, :state, :postal_code, :country, :default)
  end
end
