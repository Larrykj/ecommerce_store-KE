class Admin::BlogCategoriesController < Admin::BaseController
  before_action :set_category, only: [ :edit, :update, :destroy ]

  def index
    @categories = BlogCategory.ordered
  end

  def new
    @category = BlogCategory.new
  end

  def create
    @category = BlogCategory.new(category_params)
    if @category.save
      redirect_to admin_blog_categories_path, notice: "Blog category created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_blog_categories_path, notice: "Blog category updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_blog_categories_path, notice: "Blog category deleted successfully."
  end

  private

  def set_category
    @category = BlogCategory.find(params[:id])
  end

  def category_params
    params.require(:blog_category).permit(:name, :description, :position)
  end
end
