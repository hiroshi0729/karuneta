require "rails_helper"

RSpec.describe "ホーム", type: :request do
  let(:user) { create(:user) }

  before do
    create(:post, user: user, title: "自分の予定ネタ", scheduled_on: Date.current + 1)
    create(:post, user: user, title: "自分の構成中ネタ", status: :drafting)
    create(:post, title: "他人の予定ネタ", scheduled_on: Date.current + 1)
    create(:post, title: "他人の構成中ネタ", status: :drafting)
    login(user)
  end

  describe "GET /home" do
    it "自分のネタだけが表示される", :aggregate_failures do
      get home_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("自分の予定ネタ", "自分の構成中ネタ")
      expect(response.body).not_to include("他人の予定ネタ")
      expect(response.body).not_to include("他人の構成中ネタ")
    end

    describe "カテゴリ付きのネタが複数あるとき" do
      before do
        category_a = create(:category, user: user, name: "カテゴリA")
        category_b = create(:category, user: user, name: "カテゴリB")
        create(:post, user: user, category: category_a, scheduled_on: Date.current + 2)
        create(:post, user: user, category: category_b, scheduled_on: Date.current + 3)
        create(:post, user: user, category: category_a, status: :drafting)
        create(:post, user: user, category: category_b, status: :drafting)
      end

      # N+1 があれば Bullet.raise によって例外になり、このテストは失敗する
      it "N+1 にならない", :aggregate_failures do
        get home_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("カテゴリA", "カテゴリB")
      end
    end
  end
end
