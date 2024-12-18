require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    ScheduleCarRecommendationsJob.perform_later
  end
end

Sidekiq::Cron::Job.load_from_hash!(
  {
    'schedule_car_recommendations_job' => {
      'class' => 'ScheduleCarRecommendationsJob',
      'cron' => '0 4 * * *',
      'queue' => 'default'
    }
  }
)
