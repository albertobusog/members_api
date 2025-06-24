Rails.application.routes.draw do
  devise_for :users
   post "/graphql", to: "graphql#execute"
end
