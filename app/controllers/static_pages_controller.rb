class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: %i[top]

  # ログイン中はLPではなくホームへ
  def top
    redirect_to home_path if logged_in?
  end
end
