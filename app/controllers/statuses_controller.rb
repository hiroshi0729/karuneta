class StatusesController < ApplicationController
  def update
    # 自分のネタだけを取得する（他人のネタは 404）
    @post = current_user.posts.find(params[:post_id])

    if @post.change_status(params[:status])
      redirect_to post_path(@post), notice: "#{@post.status_label}にしました"
    else
      redirect_to post_path(@post), alert: "ステータスを変更できませんでした"
    end
  end
end
