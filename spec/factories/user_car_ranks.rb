FactoryBot.define do
  factory :user_car_rank do
    rank_score { Faker::Number.beteen(from: 0.0, to: 1.0).round(2) }
    user
    car
  end
end
