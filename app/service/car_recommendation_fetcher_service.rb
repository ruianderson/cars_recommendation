require 'net/http'
require 'json'

class CarRecommendationFetcherService
  BASE_URL = 'https://bravado-images-production.s3.amazonaws.com/recomended_cars.json'

  def run!(user_id)
    url = "#{BASE_URL}?user_id=#{user_id}"

    response = Net::HTTP.get(URI(url))
    recommendations = JSON.parse(response)

    recommendations.each do |recommendation|
      car_id = recommendation['car_id']
      rank_score = recommendation['rank_score']

      UserCarRank.find_or_initialize_by(user_id: user_id, car_id: car_id).tap do |user_car_rank|
        user_car_rank.rank_score = rank_score
        user_car_rank.save!
      end
    end
  end
end
