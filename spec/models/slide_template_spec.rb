require "rails_helper"

RSpec.describe SlideTemplate do
  describe ".labels_for" do
    it "howto は 表紙／問題提起／原因・解説／解決策／CTA の順で5つ返る" do
      expect(described_class.labels_for(:howto)).to eq(%w[表紙 問題提起 原因・解説 解決策 CTA])
    end

    it "checklist は 表紙／チェック項目1〜3／まとめ・CTA の順で5つ返る" do
      expect(described_class.labels_for(:checklist))
        .to eq(%w[表紙 チェック項目1 チェック項目2 チェック項目3 まとめ・CTA])
    end

    it "文字列で指定してもシンボルと同じ結果になる", :aggregate_failures do
      expect(described_class.labels_for("howto")).to eq(described_class.labels_for(:howto))
      expect(described_class.labels_for("checklist")).to eq(described_class.labels_for(:checklist))
    end

    it "存在しない種類を渡すと ArgumentError になる" do
      expect { described_class.labels_for(:unknown) }.to raise_error(ArgumentError)
    end

    it "nil を渡すと ArgumentError になる" do
      expect { described_class.labels_for(nil) }.to raise_error(ArgumentError)
    end
  end

  describe "LABELS" do
    it "キーが Post.template_types のキーと一致している" do
      expect(described_class::LABELS.keys.map(&:to_s)).to match_array(Post.template_types.keys)
    end

    it "どの種類もラベルが5枚分ある" do
      expect(described_class::LABELS.values).to all(have_attributes(size: 5))
    end

    it "freeze されていて書き換えられない", :aggregate_failures do
      expect(described_class::LABELS).to be_frozen
      expect(described_class::LABELS.values).to all(be_frozen)
      expect { described_class::LABELS[:howto] << "追加" }.to raise_error(FrozenError)
    end
  end

  describe "テンプレートの日本語名" do
    it "Post.template_type_label_for が日本語名を返す", :aggregate_failures do
      expect(Post.template_type_label_for(:howto)).to eq("ノウハウ紹介型")
      expect(Post.template_type_label_for(:checklist)).to eq("チェックリスト型")
    end

    it "Post#template_type_label が日本語名を返し、未選択なら nil を返す", :aggregate_failures do
      expect(build(:post, template_type: :howto).template_type_label).to eq("ノウハウ紹介型")
      expect(build(:post, template_type: :checklist).template_type_label).to eq("チェックリスト型")
      expect(build(:post, template_type: nil).template_type_label).to be_nil
    end
  end
end
