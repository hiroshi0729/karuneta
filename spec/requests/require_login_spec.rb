require "rails_helper"

RSpec.describe "ログインしていないときのアクセス", type: :request do
  let(:post_record) { create(:post).tap { |post| post.build_structure(:howto) } }

  {
    "ホーム" => -> { home_path },
    "カテゴリ一覧" => -> { categories_path },
    "ネタ一覧" => -> { posts_path },
    "ネタ詳細" => -> { post_path(post_record) },
    "ネタ登録" => -> { new_post_path },
    "構成エディタ" => -> { edit_post_structure_path(post_record) }
  }.each do |page_name, path|
    it "#{page_name}を開くとログイン画面に移動し、「ログインしてください」と表示される", :aggregate_failures do
      get instance_exec(&path)
      expect(response).to redirect_to(login_path)
      expect(flash[:alert]).to eq("ログインしてください")
    end
  end

  it "ネタを登録しようとしてもログイン画面に移動し、登録されない", :aggregate_failures do
    expect { post posts_path, params: { post: { title: "未ログインのネタ" } } }.not_to change(Post, :count)
    expect(response).to redirect_to(login_path)
  end
end
