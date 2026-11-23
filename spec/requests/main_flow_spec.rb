require "rails_helper"

RSpec.describe "主要な操作の流れ", type: :request do
  around { |example| travel_to(Date.new(2026, 11, 23)) { example.run } }

  # 登録 → ログアウト → ログイン → カテゴリ作成 → ネタ登録 → 構成作成 → 構成の保存 → 投稿準備完了 → 投稿済み を1つの流れで確かめる
  it "ユーザー登録からネタを投稿済みにするまで、順番に操作できる", :aggregate_failures do # rubocop:disable RSpec/ExampleLength
    # ユーザー登録 → ホーム
    post users_path, params: { user: { name: "岩本", email: "flow@example.com",
                                       password: "password", password_confirmation: "password" } }
    expect(response).to redirect_to(home_path)
    follow_redirect!
    expect(response.body).to include("ユーザー登録が完了しました", "次にやること")
    user = User.find_by!(email: "flow@example.com")

    # ログアウト → TOP
    delete logout_path
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("ログアウトしました")

    # ログイン → ホーム
    post login_path, params: { email: "flow@example.com", password: "password" }
    expect(response).to redirect_to(home_path)
    follow_redirect!
    expect(response.body).to include("ログインしました")

    # カテゴリを作る → カテゴリ一覧
    post categories_path, params: { category: { name: "集客ノウハウ", color: Category::COLORS.first } }
    expect(response).to redirect_to(categories_path)
    follow_redirect!
    expect(response.body).to include("カテゴリを追加しました", "集客ノウハウ")
    category = user.categories.find_by!(name: "集客ノウハウ")

    # そのカテゴリでネタを登録 → ネタ一覧
    post posts_path, params: { post: { title: "LP改善の事例", category_id: category.id, scheduled_on: "2026-11-30" } }
    expect(response).to redirect_to(posts_path)
    follow_redirect!
    expect(response.body).to include("ネタを登録しました", "LP改善の事例")
    post_record = user.posts.find_by!(title: "LP改善の事例")
    expect(post_record).to have_attributes(category: category, status: "idea", template_type: nil)

    # ネタ詳細を開く（テンプレートを選ぶ画面が出る）
    get post_path(post_record)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("LP改善の事例", "構成を作る", "ノウハウ紹介型")

    # ノウハウ紹介型で構成を作る → ネタ詳細
    post post_structure_path(post_record), params: { template_type: "howto" }
    expect(response).to redirect_to(post_path(post_record))
    follow_redirect!
    expect(response.body).to include("構成を作成しました", "構成（ノウハウ紹介型・5枚）")
    expect(post_record.reload).to have_attributes(status: "drafting", template_type: "howto")
    expect(post_record.slides.map(&:label)).to eq(%w[表紙 問題提起 原因・解説 解決策 CTA])

    # 構成エディタで見出しと本文を保存 → ネタ詳細
    get edit_post_structure_path(post_record)
    expect(response).to have_http_status(:ok)
    first_slide, second_slide = post_record.slides.first(2)
    slides_params = { post: { slides_attributes: {
      "0" => { id: first_slide.id, heading: "問い合わせが2倍に", body: "LPを見直した話" },
      "1" => { id: second_slide.id, heading: "LPで離脱されていませんか？", body: "よくある悩み" }
    } } }
    patch post_structure_path(post_record), params: slides_params
    expect(response).to redirect_to(post_path(post_record))
    follow_redirect!
    expect(response.body).to include("構成を保存しました", "問い合わせが2倍に", "LPで離脱されていませんか？")
    expect(first_slide.reload).to have_attributes(heading: "問い合わせが2倍に", body: "LPを見直した話")
    expect(post_record.reload).to be_drafting

    # 投稿準備完了にする → ネタ詳細
    patch post_structure_path(post_record), params: slides_params.merge(mark_ready: "投稿準備完了にする")
    expect(response).to redirect_to(post_path(post_record))
    follow_redirect!
    expect(response.body).to include("構成を保存し、投稿準備完了にしました", "投稿済みにする")
    expect(post_record.reload).to have_attributes(status: "ready", posted_on: nil)

    # 投稿済みにする → ネタ詳細（投稿日が入り、ボタンが消える）
    patch post_status_path(post_record), params: { status: "posted" }
    expect(response).to redirect_to(post_path(post_record))
    follow_redirect!
    expect(response.body).to include("投稿済みにしました", "11/23")
    expect(response.body).not_to include("投稿済みにする")
    expect(post_record.reload).to have_attributes(status: "posted", posted_on: Date.new(2026, 11, 23))
    expect(post_record.slides.count).to eq(5)
  end
end
