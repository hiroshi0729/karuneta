require "rails_helper"

RSpec.describe Category, type: :model do
  describe "バリデーション" do
    it "すべての項目が正しければ有効" do
      expect(build(:category)).to be_valid
    end

    it "名前が空だと無効" do
      expect(build(:category, name: "")).not_to be_valid
    end

    it "名前が20文字なら有効" do
      expect(build(:category, name: "あ" * 20)).to be_valid
    end

    it "名前が21文字以上だと無効" do
      expect(build(:category, name: "あ" * 21)).not_to be_valid
    end

    it "同じユーザーで同じ名前のカテゴリがあると無効" do
      category = create(:category, name: "集客")
      expect(build(:category, user: category.user, name: "集客")).not_to be_valid
    end

    it "別のユーザーなら同じ名前でも有効" do
      create(:category, name: "集客")
      expect(build(:category, name: "集客")).to be_valid
    end

    it "COLORS にある色はすべて有効" do
      expect(Category::COLORS.map { |color| build(:category, color: color) }).to all(be_valid)
    end

    it "COLORS にない色だと無効" do
      expect(build(:category, color: "#000000")).not_to be_valid
    end
  end

  describe ".ordered" do
    it "登録した順に並ぶ" do
      user = create(:user)
      newer = create(:category, user: user, created_at: 1.day.ago)
      older = create(:category, user: user, created_at: 2.days.ago)
      expect(user.categories.ordered).to eq([ older, newer ])
    end
  end

  describe "削除" do
    it "カテゴリを削除すると、そのカテゴリのネタは残り、カテゴリが nil になる", :aggregate_failures do
      category = create(:category)
      post = create(:post, user: category.user, category: category)

      expect { category.destroy }.not_to change(Post, :count)
      expect(post.reload.category).to be_nil
    end
  end
end
