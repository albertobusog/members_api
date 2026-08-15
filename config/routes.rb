Rails.application.routes.draw do
  devise_for :users

  # Health checks for the hosting provider (Render/Fly) and uptime probes.
  get "/up", to: "rails/health#show", as: :rails_health_check
  get "/health", to: "health#show"

  post "/graphql", to: "graphql#execute"
end
