require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  get '/cars', to: 'cars#search'
  mount Sidekiq::Web => '/sidekiq'
end
