require "rails_helper"

RSpec.describe "静的ページ", type: :request do
  describe "トップページ（GET /）" do
    before { get root_path }

    it "正常に表示される（ステータス200）" do
      expect(response).to have_http_status(:ok)
    end

    it "キャッチコピー「思いついたネタを、」が表示される" do
      expect(response.body).to include("思いついたネタを、")
    end
  end
end
