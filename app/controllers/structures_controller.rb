class StructuresController < ApplicationController
  # 自分のネタだけを取得する（他人のネタは 404）
  before_action :set_post
  before_action :require_structure, only: %i[edit update]

  def create
    if @post.build_structure(params[:template_type])
      redirect_to post_path(@post), notice: "構成を作成しました"
    else
      redirect_to post_path(@post), alert: "構成を作成できませんでした"
    end
  end

  def edit; end

  def update
    mark_ready = params[:mark_ready].present?
    if @post.update_structure(structure_params, mark_ready: mark_ready)
      redirect_to post_path(@post), notice: mark_ready ? "構成を保存し、投稿準備完了にしました" : "構成を保存しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_post
    @post = current_user.posts.find(params[:post_id])
  end

  def require_structure
    redirect_to post_path(@post), alert: "先に構成を作ってください" if @post.template_type.nil?
  end

  # 見出し・本文だけを受け取る（並び順・ラベル・ネタは変更させない）
  def structure_params
    params.require(:post).permit(slides_attributes: %i[id heading body])
  end
end
