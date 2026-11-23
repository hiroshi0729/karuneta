require "rails_helper"

RSpec.describe "ステータスの変更", type: :request do
  let(:user) { create(:user) }
  let(:post_record) { create(:post, user: user, status: :ready) }

  before { login(user) }

  describe "PATCH /posts/:post_id/status" do
    it "「投稿済みにする」で投稿済みになり、投稿日に今日の日付が入る", :aggregate_failures do
      travel_to(Date.new(2026, 11, 23)) { patch post_status_path(post_record), params: { status: "posted" } }
      expect(response).to redirect_to(post_path(post_record))
      expect(flash[:notice]).to eq("投稿済みにしました")
      expect(post_record.reload).to have_attributes(status: "posted", posted_on: Date.new(2026, 11, 23))
    end

    [ "idea", "unknown" ].each do |invalid_status|
      it "#{invalid_status} を送るとステータスは変わらない", :aggregate_failures do
        patch post_status_path(post_record), params: { status: invalid_status }
        expect(response).to redirect_to(post_path(post_record))
        expect(flash[:alert]).to eq("ステータスを変更できませんでした")
        expect(post_record.reload).to be_ready
      end
    end
  end
end
