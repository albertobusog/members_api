Rails.application.routes.draw do
  
  get "about-us", to: "about#index", as: :about

  root to: "main#index"
 
  get "up" => "rails/health#show", as: :rails_health_check

  
end
