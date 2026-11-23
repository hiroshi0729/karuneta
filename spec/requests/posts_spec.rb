require "rails_helper"

RSpec.describe "ネタ", type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user) }
  let(:post_record) { create(:post, user: user, title: "登録済みのネタ") }

  before { login(user) }

  describe "GET /posts" do
    before do
      create(:post, user: user, title: "アイデア段階のネタ", status: :idea)
      create(:post, user: user, title: "構成を作っているネタ", status: :drafting)
    end

    it "ステータスを指定しなければ、すべてのネタが表示される", :aggregate_failures do
      get posts_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("アイデア段階のネタ", "構成を作っているネタ")
    end

    it "ステータスで絞り込める", :aggregate_failures do
      get posts_path, params: { status: "drafting" }
      expect(response.body).to include("構成を作っているネタ")
      expect(response.body).not_to include("アイデア段階のネタ")
    end

    it "不正なステータスなら、すべてのネタが表示される" do
      get posts_path, params: { status: "unknown" }
      expect(response.body).to include("アイデア段階のネタ", "構成を作っているネタ")
    end
  end

  describe "GET /posts/:id" do
    it "ネタの詳細が表示される", :aggregate_failures do
      get post_path(post_record)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("登録済みのネタ")
    end
  end

  describe "GET /posts/new" do
    it "登録画面が表示される" do
      get new_post_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /posts" do
    it "正しい値なら登録でき、ネタ一覧に移動する", :aggregate_failures do
      params = { post: { title: "新しいネタ", category_id: category.id, scheduled_on: "2026-12-01", memo: "メモ" } }
      expect { post posts_path, params: params }.to change(user.posts, :count).by(1)
      expect(response).to redirect_to(posts_path)
      expect(flash[:notice]).to eq("ネタを登録しました")
      expect(user.posts.last).to have_attributes(title: "新しいネタ", category: category, memo: "メモ")
    end

    it "status を送っても、ステータスは idea のまま" do
      post posts_path, params: { post: { title: "新しいネタ", status: "posted" } }
      expect(user.posts.last).to be_idea
    end

    it "タイトルが空だと登録できず、登録画面がエラーで表示される", :aggregate_failures do
      expect { post posts_path, params: { post: { title: "" } } }.not_to change(Post, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /posts/:id/edit" do
    it "編集画面が表示される", :aggregate_failures do
      get edit_post_path(post_record)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("登録済みのネタ")
    end
  end

  describe "PATCH /posts/:id" do
    it "正しい値なら更新でき、ネタ詳細に移動する", :aggregate_failures do
      patch post_path(post_record), params: { post: { title: "更新したネタ", category_id: category.id } }
      expect(response).to redirect_to(post_path(post_record))
      expect(flash[:notice]).to eq("ネタを更新しました")
      expect(post_record.reload).to have_attributes(title: "更新したネタ", category: category)
    end

    it "ステータスも変更できる" do
      patch post_path(post_record), params: { post: { status: "ready" } }
      expect(post_record.reload).to be_ready
    end

    it "タイトルが空だと更新できず、編集画面がエラーで表示される", :aggregate_failures do
      patch post_path(post_record), params: { post: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(post_record.reload.title).to eq("登録済みのネタ")
    end

    it "不正なステータスだと更新できない", :aggregate_failures do
      patch post_path(post_record), params: { post: { status: "unknown" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(post_record.reload).to be_idea
    end
  end

  describe "DELETE /posts/:id" do
    it "削除でき、構成（スライド）も一緒に削除され、ネタ一覧に移動する", :aggregate_failures do
      post_record.build_structure(:howto)
      expect { delete post_path(post_record) }.to change(Post, :count).by(-1).and change(Slide, :count).by(-5)
      expect(response).to redirect_to(posts_path)
      expect(flash[:notice]).to eq("ネタを削除しました")
    end
  end
end
