class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  has_many :slides, -> { order(:position) }, dependent: :destroy, inverse_of: :post

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

  # テンプレートを選んで構成を作る（見出しのひな形が入ったスライドを作り、ステータスを「構成中」にする）
  # すでに構成がある・テンプレートの種類が不正・保存に失敗したときは、何も変えずに false を返す
  def build_structure(new_template_type)
    with_lock do
      return false if template_type.present? || slides.exists?
      return false unless self.class.template_types.key?(new_template_type.to_s)

      update!(template_type: new_template_type, status: :drafting)
      SlideTemplate.labels_for(new_template_type).each.with_index(1) do |label, position|
        slides.create!(position: position, label: label)
      end
    end
    true
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    false
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
