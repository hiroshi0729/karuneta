FactoryBot.define do
  factory :category do
    association :user
    sequence(:name) { |n| "カテゴリ#{n}" }
    color { Category::COLORS.first }
  end
end
