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
  end
end
