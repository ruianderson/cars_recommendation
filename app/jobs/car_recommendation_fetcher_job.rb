class CarRecommendationFetcherJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    CarRecommendationFetcherService.new.run!(user_id)
  end
end
