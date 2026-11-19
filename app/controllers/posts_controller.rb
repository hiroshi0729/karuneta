class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update]

  def index
    @posts = current_user.posts.includes(:category).with_status(params[:status]).by_schedule
  end

  def show; end

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

  def edit
    @categories = current_user.categories.order(:created_at)
  end

  def update
    if @post.update(update_post_params)
      redirect_to post_path(@post), notice: "ネタを更新しました"
    else
      @categories = current_user.categories.order(:created_at)
      render :edit, status: :unprocessable_content
    end
  end

  private

  # 自分のネタだけを取得する（他人のネタは 404）
  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :category_id, :scheduled_on, :memo)
  end

  # 更新時だけステータスも変更できる
  def update_post_params
    params.require(:post).permit(:title, :category_id, :scheduled_on, :memo, :status)
  end
end
