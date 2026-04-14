class BlogCommentsController < ApplicationController
  before_action :authenticate_user!, only: [ :create ]

  def create
    @post = BlogPost.find(params[:blog_post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user if user_signed_in?

    if @comment.save
      redirect_to @post, notice: "Comment posted!"
    else
      redirect_to @post, alert: "Could not post comment."
    end
  end

  def destroy
    @comment = BlogComment.find(params[:id])
    authorize! :destroy, @comment
    @comment.destroy
    redirect_to @comment.post, notice: "Comment deleted."
  end

  private

  def comment_params
    params.require(:blog_comment).permit(:content, :name, :email, :parent_id)
  end
end
