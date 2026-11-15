class CategoriesController < ApplicationController
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

  private

  def category_params
    params.require(:category).permit(:name, :color)
  end
end
