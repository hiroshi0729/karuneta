class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  enum :status, { idea: 0, drafting: 1, ready: 2, posted: 3 }
  enum :template_type, { howto: 0, checklist: 1 }

  validates :title, presence: true, length: { maximum: 100 }
  validates :memo, length: { maximum: 1000 }
  validate :category_belongs_to_user

  private

  def category_belongs_to_user
    return if category.nil?

    errors.add(:category, :invalid) unless category.user_id == user_id
  end
end
