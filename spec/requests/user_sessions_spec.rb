require "rails_helper"

RSpec.describe "ログイン・ログアウト", type: :request do
  let(:user) { create(:user) }

  describe "GET /login" do
    it "ログイン画面が表示される" do
      get login_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /login" do
    it "正しいメールアドレスとパスワードならログインでき、ホームに移動する", :aggregate_failures do
      login(user)
      expect(response).to redirect_to(home_path)
      expect(flash[:notice]).to eq("ログインしました")
    end

    it "パスワードが違うとログインできず、エラーが表示される", :aggregate_failures do
      login(user, password: "wrongpass")
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("メールアドレスまたはパスワードが違います")
    end

    it "ログインに失敗したあとはホームを開けない" do
      login(user, password: "wrongpass")
      get home_path
      expect(response).to redirect_to(login_path)
    end
  end

  describe "DELETE /logout" do
    before do
      login(user)
      delete logout_path
    end

    it "ログアウトするとTOPに移動する", :aggregate_failures do
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("ログアウトしました")
    end

    it "ログアウトしたあとはホームを開けない" do
      get home_path
      expect(response).to redirect_to(login_path)
    end
  end
end
