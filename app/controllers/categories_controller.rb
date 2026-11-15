class CategoriesController < ApplicationController
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = current_user.categories.order(:created_at)
    @category = current_user.categories.build(color: Category::COLORS.first)
  end

  def create
    @category = current_user.categories.build(category_params)
    if @category.save
      redirect_to categories_path, notice: "カテゴリを追加しました"
    else
      @categories = current_user.categories.order(:created_at)
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

  def category_params
    params.require(:category).permit(:name, :color)
  end
end
