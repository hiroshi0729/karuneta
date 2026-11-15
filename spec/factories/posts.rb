FactoryBot.define do
  factory :post do
    association :user
    sequence(:title) { |n| "ネタ#{n}" }
  end
end
