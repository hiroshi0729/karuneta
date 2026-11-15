require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it "すべての項目が正しければ有効" do
      expect(build(:user)).to be_valid
    end

    it "ユーザー名が空だと無効で、日本語のエラーメッセージが出る", :aggregate_failures do
      user = build(:user, name: "")
      expect(user).not_to be_valid
      expect(user.errors.full_messages).to include("ユーザー名を入力してください")
    end

    it "ユーザー名が50文字なら有効" do
      expect(build(:user, name: "あ" * 50)).to be_valid
    end

    it "ユーザー名が51文字以上だと無効" do
      expect(build(:user, name: "あ" * 51)).not_to be_valid
    end

    it "メールアドレスが空だと無効で、エラーは「入力してください」の1つだけ", :aggregate_failures do
      user = build(:user, email: "")
      expect(user).not_to be_valid
      expect(user.errors.full_messages_for(:email)).to eq([ "メールアドレスを入力してください" ])
    end

    it "メールアドレスが重複していると無効" do
      create(:user, email: "taken@example.com")
      expect(build(:user, email: "taken@example.com")).not_to be_valid
    end

    it "メールアドレスの形式が正しくないと無効" do
      expect(build(:user, email: "invalid-email")).not_to be_valid
    end

    it "パスワードが8文字なら有効" do
      expect(build(:user, password: "a" * 8, password_confirmation: "a" * 8)).to be_valid
    end

    it "パスワードが7文字以下だと無効" do
      expect(build(:user, password: "a" * 7, password_confirmation: "a" * 7)).not_to be_valid
    end

    it "パスワード（確認）が一致しないと無効" do
      expect(build(:user, password_confirmation: "different")).not_to be_valid
    end

    it "パスワード（確認）が空だと無効" do
      expect(build(:user, password_confirmation: "")).not_to be_valid
    end

    it "登録済みユーザーはパスワードを変更しなければ、パスワードなしで更新できる" do
      user = create(:user)
      user = described_class.find(user.id)
      expect(user.update(name: "新しい名前")).to be true
    end
  end
end
