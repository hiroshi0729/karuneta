require "rails_helper"

RSpec.describe Slide, type: :model do
  describe "バリデーション" do
    it "すべての項目が正しければ有効" do
      expect(build(:slide)).to be_valid
    end

    it "順番（position）が空だと無効" do
      expect(build(:slide, position: nil)).not_to be_valid
    end

    it "ラベルが空だと無効" do
      expect(build(:slide, label: "")).not_to be_valid
    end

    it "同じネタで同じ順番のスライドがあると無効" do
      slide = create(:slide, position: 1)
      expect(build(:slide, post: slide.post, position: 1)).not_to be_valid
    end

    it "別のネタなら同じ順番でも有効" do
      create(:slide, position: 1)
      expect(build(:slide, position: 1)).to be_valid
    end

    it "見出しが100文字なら有効" do
      expect(build(:slide, heading: "あ" * 100)).to be_valid
    end

    it "見出しが101文字以上だと無効" do
      expect(build(:slide, heading: "あ" * 101)).not_to be_valid
    end

    it "本文が1000文字なら有効" do
      expect(build(:slide, body: "あ" * 1000)).to be_valid
    end

    it "本文が1001文字以上だと無効" do
      expect(build(:slide, body: "あ" * 1001)).not_to be_valid
    end
  end
end
