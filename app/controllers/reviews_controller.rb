class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_review, only: [ :edit, :update, :destroy, :helpful ]
  before_action :authorize_review, only: [ :edit, :update, :destroy ]

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    respond_to do |format|
      if @review.save
        format.html { redirect_to @product, notice: t("review_submitted_success") }
      else
        format.html { redirect_to @product, alert: @review.errors.full_messages.join(", ") }
        format.turbo_stream { flash.now[:alert] = @review.errors.full_messages.join(", ") }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to @product, notice: t("review_updated_success") }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @review.destroy
    respond_to do |format|
      format.html { redirect_to @product, notice: t("review_deleted_success") }
      format.turbo_stream { flash.now[:notice] = t("review_deleted_success") }
    end
  end

  # Mark review as helpful
  def helpful
    @review.mark_helpful!
    respond_to do |format|
      format.html { redirect_to @product, notice: t("review_helpful_thanks") }
      format.turbo_stream { render turbo_stream: [
        turbo_stream.replace("review_helpful_container_#{@review.id}", %(<div id="review_helpful_container_#{@review.id}" style="display:inline-block;"><form class="button_to" method="post" action="#{helpful_product_review_path(@product, @review)}"><button class="helpful-btn" type="submit"><i class="bi bi-hand-thumbs-up"></i> #{t("helpful")} (#{@review.helpful_count})</button></form></div>).html_safe),
        turbo_stream.append("toastContainer", "<script>showToast('#{t("review_helpful_thanks", default: "Thanks for your feedback!")}', 'success')</script>".html_safe)
      ] }
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_review
    @review = @product.reviews.find(params[:id])
  end

  def authorize_review
    unless @review.editable_by?(current_user)
      redirect_to @product, alert: t("not_authorized")
    end
  end

  def review_params
    params.require(:review).permit(:rating, :title, :content)
  end
end
