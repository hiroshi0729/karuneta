FactoryBot.define do
  factory :slide do
    association :post
    sequence(:position) { |n| n }
    label { "表紙" }
  end
end
