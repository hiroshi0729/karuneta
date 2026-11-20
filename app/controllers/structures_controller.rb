class StructuresController < ApplicationController
  def create
    # 自分のネタだけを取得する（他人のネタは 404）
    @post = current_user.posts.find(params[:post_id])
    if @post.build_structure(params[:template_type])
      redirect_to post_path(@post), notice: "構成を作成しました"
    else
      redirect_to post_path(@post), alert: "構成を作成できませんでした"
    end
  end
end
