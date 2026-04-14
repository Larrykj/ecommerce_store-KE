class BlogPostsController < ApplicationController
  before_action :set_post, only: [ :show ]

  def index
    @pagy, @posts = pagy(BlogPost.published.recent, items: 10)
    @categories = BlogCategory.ordered
  end

  def show
    @post.increment!(:views_count)
    @comments = @post.comments.approved.top_level.recent
  end

  private

  def set_post
    @post = BlogPost.published.find_by!(slug: params[:id])
  end
end
