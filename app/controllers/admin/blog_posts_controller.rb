class Admin::BlogPostsController < Admin::BaseController
  def index
    @pagy, @posts = pagy(BlogPost.all.includes(:user, :category).order(created_at: :desc), items: 20)
  end

  def new
    @post = BlogPost.new
  end

  def create
    @post = current_user.blog_posts.build(post_params)
    if @post.save
      redirect_to admin_blog_posts_path, notice: "Post created!"
    else
      render :new
    end
  end

  def edit
    @post = BlogPost.find(params[:id])
  end

  def update
    @post = BlogPost.find(params[:id])
    if @post.update(post_params)
      redirect_to admin_blog_posts_path, notice: "Post updated!"
    else
      render :edit
    end
  end

  def destroy
    @post = BlogPost.find(params[:id])
    @post.destroy
    redirect_to admin_blog_posts_path, notice: "Post deleted."
  end

  private

  def post_params
    params.require(:blog_post).permit(:title, :slug, :excerpt, :content, :category_id, :featured_image, :meta_title, :meta_description, :published, :published_at)
  end
end
