class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]
  before_action :set_categories, only: %i[index create]

  def index
    @category = current_user.categories.build(color: Category::COLORS.first)
  end

  def create
    @category = current_user.categories.build(category_params)
    if @category.save
      redirect_to categories_path, notice: "カテゴリを追加しました"
    else
      render :index, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "カテゴリを更新しました"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @category.destroy!
    redirect_to categories_path, notice: "カテゴリを削除しました", status: :see_other
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  # 一覧に出す自分のカテゴリ。リレーションは遅延評価なので、保存に成功したときは SQL を実行しない
  def set_categories
    @categories = current_user.categories.ordered
  end

  def category_params
    params.require(:category).permit(:name, :color)
  end
end
