FactoryBot.define do
  factory :car do
    model { Faker::Vehicle.model }
    association :brand
  end
end
