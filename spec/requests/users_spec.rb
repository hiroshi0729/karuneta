require "rails_helper"

RSpec.describe "ユーザー登録", type: :request do
  let(:valid_params) do
    { user: { name: "岩本", email: "new@example.com", password: "password", password_confirmation: "password" } }
  end

  describe "GET /users/new" do
    it "登録画面が表示される" do
      get new_user_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /users" do
    it "正しい値なら登録でき、ログインした状態でホームに移動する", :aggregate_failures do
      expect { post users_path, params: valid_params }.to change(User, :count).by(1)
      expect(response).to redirect_to(home_path)
      expect(flash[:notice]).to eq("ユーザー登録が完了しました")
      get home_path
      expect(response).to have_http_status(:ok)
    end

    it "パスワード（確認）が一致しないと登録できず、画面にエラーが表示される", :aggregate_failures do
      valid_params[:user][:password_confirmation] = "different"
      expect { post users_path, params: valid_params }.not_to change(User, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
