class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  # 不正な値が送られたときは例外ではなく入力エラーとして扱う
  enum :status, { idea: 0, drafting: 1, ready: 2, posted: 3 }, validate: true
  enum :template_type, { howto: 0, checklist: 1 }

  validates :title, presence: true, length: { maximum: 100 }
  validates :memo, length: { maximum: 1000 }
  validate :category_belongs_to_user

  before_save :sync_posted_on, if: :will_save_change_to_status?

  # 有効なステータスのときだけ絞り込み、空や不正な値なら全件を返す
  scope :with_status, ->(status) { statuses.key?(status) ? where(status: status) : all }
  # 投稿予定日が近い順（予定日なしは後ろ）、同じなら新しく登録した順
  scope :by_schedule, -> { order(arel_table[:scheduled_on].asc.nulls_last).order(created_at: :desc) }

  def self.status_label_for(status)
    human_attribute_name("status.#{status}")
  end

  def status_label
    self.class.status_label_for(status)
  end

  def self.template_type_label_for(template_type)
    human_attribute_name("template_type.#{template_type}")
  end

  # テンプレート未選択（nil）のときは nil を返す
  def template_type_label
    self.class.template_type_label_for(template_type) if template_type
  end

  private

  # ステータスが変わったときだけ投稿日をそろえる
  # 投稿済みになったら（未設定なら）今日の日付を入れ、それ以外に戻したら空にする
  def sync_posted_on
    if posted?
      self.posted_on ||= Date.current
    else
      self.posted_on = nil
    end
  end

  def category_belongs_to_user
    return if category.nil?

    errors.add(:category, :invalid) unless category.user_id == user_id
  end
end
