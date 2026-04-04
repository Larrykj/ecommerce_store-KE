# frozen_string_literal: true

class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [ :edit, :update, :destroy, :restore ]

  def index
    @categories = Category.unscoped.order(name: :asc)
    @categories = @categories.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_categories_path, notice: "Category created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path, notice: "Category updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.discard
    redirect_to admin_categories_path, notice: "Category archived successfully."
  end

  def restore
    @category.undiscard
    redirect_to admin_categories_path, notice: "Category restored successfully."
  end

  private

  def set_category
    @category = Category.unscoped.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description, :image)
  end
end
