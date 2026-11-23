require "rails_helper"

RSpec.describe "ほかのユーザーのデータへのアクセス", type: :request do
  let(:other_category) { create(:category, name: "他人のカテゴリ") }
  let(:other_post) do
    create(:post, title: "他人のネタ", status: :drafting).tap { |post| post.build_structure(:howto) }
  end

  before { login(create(:user)) }

  describe "カテゴリ" do
    it "編集画面を開くと 404 になる" do
      get edit_category_path(other_category)
      expect(response).to have_http_status(:not_found)
    end

    it "更新しようとすると 404 になり、変わらない", :aggregate_failures do
      patch category_path(other_category), params: { category: { name: "書き換え" } }
      expect(response).to have_http_status(:not_found)
      expect(other_category.reload.name).to eq("他人のカテゴリ")
    end

    it "削除しようとすると 404 になり、削除されない", :aggregate_failures do
      other_category
      expect { delete category_path(other_category) }.not_to change(Category, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "ネタ" do
    it "詳細を開くと 404 になる" do
      get post_path(other_post)
      expect(response).to have_http_status(:not_found)
    end

    it "編集画面を開くと 404 になる" do
      get edit_post_path(other_post)
      expect(response).to have_http_status(:not_found)
    end

    it "更新しようとすると 404 になり、変わらない", :aggregate_failures do
      patch post_path(other_post), params: { post: { title: "書き換え" } }
      expect(response).to have_http_status(:not_found)
      expect(other_post.reload.title).to eq("他人のネタ")
    end

    it "削除しようとすると 404 になり、削除されない", :aggregate_failures do
      other_post
      expect { delete post_path(other_post) }.not_to change(Post, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "構成" do
    it "作成しようとすると 404 になり、作られない", :aggregate_failures do
      other_post = create(:post)
      expect { post post_structure_path(other_post), params: { template_type: "howto" } }.not_to change(Slide, :count)
      expect(response).to have_http_status(:not_found)
    end

    it "構成エディタを開くと 404 になる" do
      get edit_post_structure_path(other_post)
      expect(response).to have_http_status(:not_found)
    end

    it "保存しようとすると 404 になり、変わらない", :aggregate_failures do
      slide = other_post.slides.first
      slides_attributes = { "0" => { id: slide.id, heading: "書き換え" } }
      patch post_structure_path(other_post), params: { post: { slides_attributes: }, mark_ready: "1" }
      expect(response).to have_http_status(:not_found)
      expect([ slide.reload.heading, other_post.reload.status ]).to eq([ nil, "drafting" ])
    end
  end

  describe "ステータス" do
    it "変更しようとすると 404 になり、変わらない", :aggregate_failures do
      patch post_status_path(other_post), params: { status: "posted" }
      expect(response).to have_http_status(:not_found)
      expect(other_post.reload).to have_attributes(status: "drafting", posted_on: nil)
    end
  end
end
