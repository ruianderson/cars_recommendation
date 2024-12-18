FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    preferred_price_range { 35_000...40_000 }
  end
end
