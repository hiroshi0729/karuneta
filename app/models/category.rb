class Category < ApplicationRecord
  COLORS = %w[#1E40AF #115E59 #5B21B6 #C2410C #4B5563].freeze

  belongs_to :user
  has_many :posts, dependent: :nullify

  validates :name, presence: true, length: { maximum: 20 }, uniqueness: { scope: :user_id }
  validates :color, presence: true, inclusion: { in: COLORS }

  # 登録した順
  scope :ordered, -> { order(:created_at) }
end
