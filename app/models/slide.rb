class Slide < ApplicationRecord
  belongs_to :post

  validates :position, presence: true,
                       numericality: { only_integer: true, greater_than_or_equal_to: 1 },
                       uniqueness: { scope: :post_id }
  validates :label, presence: true
  validates :heading, length: { maximum: 100 }
  validates :body, length: { maximum: 1000 }
end
