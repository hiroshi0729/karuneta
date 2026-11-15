module PostsHelper
  STATUS_BADGE_CLASSES = {
    "idea" => "bg-gray-100 text-gray-700",
    "drafting" => "bg-orange-100 text-orange-700",
    "ready" => "bg-green-100 text-green-700",
    "posted" => "bg-blue-100 text-blue-700"
  }.freeze

  BADGE_BASE_CLASS = "rounded-full px-2 py-0.5 text-xs font-bold".freeze

  def status_badge_class(status)
    "#{BADGE_BASE_CLASS} #{STATUS_BADGE_CLASSES.fetch(status, STATUS_BADGE_CLASSES['idea'])}"
  end

  def category_badge_class
    BADGE_BASE_CLASS
  end

  # 文字はカテゴリの色、背景は同じ色に透明度（1A ≒ 10%）を付けたもの
  def category_badge_style(category)
    "color: #{category.color}; background-color: #{category.color}1A;"
  end

  # 不正な値や空のときは nil（＝「すべて」を選んでいる状態）
  def current_status_filter
    params[:status] if Post.statuses.key?(params[:status])
  end

  def status_filter_class(selected)
    base = "rounded-full border px-4 py-1.5 text-sm font-bold"
    selected ? "#{base} border-footer bg-footer text-white" : "#{base} border-gray-300 bg-white text-gray-700"
  end
end
