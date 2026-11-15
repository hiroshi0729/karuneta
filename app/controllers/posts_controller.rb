class PostsController < ApplicationController
  def index
    @posts = current_user.posts.includes(:category).with_status(params[:status]).by_schedule
  end

  def new
    @post = current_user.posts.build
    @categories = current_user.categories.order(:created_at)
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to posts_path, notice: "ネタを登録しました"
    else
      @categories = current_user.categories.order(:created_at)
      render :new, status: :unprocessable_content
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :category_id, :scheduled_on, :memo)
  end
end
