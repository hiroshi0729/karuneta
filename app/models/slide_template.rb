# 構成テンプレートごとのスライド5枚分の見出し（ラベル）。
# キーは Post の template_type と同じ名前にそろえる。
module SlideTemplate
  LABELS = {
    howto: %w[表紙 問題提起 原因・解説 解決策 CTA].map(&:freeze).freeze,
    checklist: %w[表紙 チェック項目1 チェック項目2 チェック項目3 まとめ・CTA].map(&:freeze).freeze
  }.freeze

  # 種類（文字列・シンボルどちらでも可）を受け取り、5枚分のラベルを順番どおりに返す
  def self.labels_for(template_type)
    LABELS.fetch(template_type.to_s.to_sym) do
      raise ArgumentError, "unknown template_type: #{template_type.inspect}"
    end
  end
end
