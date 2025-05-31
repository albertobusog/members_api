Rails.application.routes.draw do
  
  get "about-us", to: "about#index", as: :about

  get  "sing_up", to: "registrations#new"
  post "sing_up", to: "registrations#create"
  
  get  "sing_in", to: "sessions#new"
  post "sing_in", to: "sessions#create"  
  
  delete "logout", to: "sessions#destroy"

  root to: "main#index"
 
  get "up" => "rails/health#show", as: :rails_health_check

  
end
