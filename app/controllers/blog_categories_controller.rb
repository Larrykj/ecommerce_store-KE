class BlogCategoriesController < ApplicationController
  def index
    @categories = BlogCategory.ordered.includes(:posts)
  end

  def show
    @category = BlogCategory.find_by(slug: params[:id]) || BlogCategory.find(params[:id])
    @pagy, @posts = pagy(@category.posts.published.recent, items: 10)
  end
end
