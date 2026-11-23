require "rails_helper"

RSpec.describe "カテゴリ", type: :request do
  let(:user) { create(:user) }
  let!(:category) { create(:category, user: user, name: "集客ノウハウ") }

  before { login(user) }

  describe "GET /categories" do
    it "自分のカテゴリが一覧に表示される", :aggregate_failures do
      get categories_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("集客ノウハウ")
    end
  end

  describe "POST /categories" do
    it "正しい値なら作成でき、カテゴリ一覧に移動する", :aggregate_failures do
      params = { category: { name: "SNS運用", color: Category::COLORS.last } }
      expect { post categories_path, params: params }.to change(user.categories, :count).by(1)
      expect(response).to redirect_to(categories_path)
      expect(flash[:notice]).to eq("カテゴリを追加しました")
    end

    it "名前が空だと作成できず、一覧画面がエラーで表示される", :aggregate_failures do
      params = { category: { name: "", color: Category::COLORS.first } }
      expect { post categories_path, params: params }.not_to change(Category, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /categories/:id/edit" do
    it "編集画面が表示される", :aggregate_failures do
      get edit_category_path(category)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("集客ノウハウ")
    end
  end

  describe "PATCH /categories/:id" do
    it "正しい値なら更新でき、カテゴリ一覧に移動する", :aggregate_failures do
      patch category_path(category), params: { category: { name: "新しい名前", color: Category::COLORS.second } }
      expect(response).to redirect_to(categories_path)
      expect(flash[:notice]).to eq("カテゴリを更新しました")
      expect(category.reload).to have_attributes(name: "新しい名前", color: Category::COLORS.second)
    end

    it "COLORS にない色だと更新できず、編集画面がエラーで表示される", :aggregate_failures do
      patch category_path(category), params: { category: { name: "新しい名前", color: "#000000" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(category.reload.name).to eq("集客ノウハウ")
    end
  end

  describe "DELETE /categories/:id" do
    it "削除でき、カテゴリ一覧に移動する", :aggregate_failures do
      expect { delete category_path(category) }.to change(Category, :count).by(-1)
      expect(response).to redirect_to(categories_path)
      expect(response).to have_http_status(:see_other)
      expect(flash[:notice]).to eq("カテゴリを削除しました")
    end
  end
end
