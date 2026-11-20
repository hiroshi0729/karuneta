# 構成テンプレートごとのスライド5枚分の見出し（ラベル）。
# キーは Post の template_type と同じ名前にそろえる。
module SlideTemplate
  LABELS = {
    howto: %w[表紙 問題提起 原因・解説 解決策 CTA].map(&:freeze).freeze,
    checklist: %w[表紙 チェック項目1 チェック項目2 チェック項目3 まとめ・CTA].map(&:freeze).freeze
  }.freeze

  # ラベルごとの見出しの入力例（構成エディタのプレースホルダー）
  HEADING_PLACEHOLDERS = {
    "表紙" => "例：思わず読みたくなるタイトル",
    "問題提起" => "例：読者が困っていること",
    "原因・解説" => "例：なぜその問題が起こるのか",
    "解決策" => "例：具体的に実践できること",
    "CTA" => "例：保存・相談・プロフィールへの誘導",
    "チェック項目1" => "例：チェックしたいポイント",
    "チェック項目2" => "例：チェックしたいポイント",
    "チェック項目3" => "例：チェックしたいポイント",
    "まとめ・CTA" => "例：まとめと次にしてほしい行動"
  }.freeze
  DEFAULT_HEADING_PLACEHOLDER = "見出しを入力".freeze

  # 種類（文字列・シンボルどちらでも可）を受け取り、5枚分のラベルを順番どおりに返す
  def self.labels_for(template_type)
    LABELS.fetch(template_type.to_s.to_sym) do
      raise ArgumentError, "unknown template_type: #{template_type.inspect}"
    end
  end

  # ラベルを受け取り、見出しの入力例を返す（定義にないラベルのときは「見出しを入力」）
  def self.heading_placeholder_for(label)
    HEADING_PLACEHOLDERS.fetch(label.to_s, DEFAULT_HEADING_PLACEHOLDER)
  end
end
