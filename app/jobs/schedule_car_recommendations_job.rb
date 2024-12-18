class ScheduleCarRecommendationsJob < ApplicationJob
  def perform(*args)
    User.find_each do |user|
      CarRecommendationFetcherJob.perform_later(user.id)
    end
  end
end
