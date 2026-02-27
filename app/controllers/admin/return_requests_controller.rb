# frozen_string_literal: true

class Admin::ReturnRequestsController < Admin::BaseController
  def index
    @return_requests = ReturnRequest.recent.includes(:order, :user)
    @return_requests = @return_requests.where(status: params[:status]) if params[:status].present?
  end

  def show
    @return_request = ReturnRequest.find(params[:id])
  end

  def update
    @return_request = ReturnRequest.find(params[:id])
    if @return_request.update(return_request_admin_params)
      redirect_to admin_return_request_path(@return_request), notice: "Return request updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def return_request_admin_params
    params.require(:return_request).permit(:status, :admin_notes)
  end
end
