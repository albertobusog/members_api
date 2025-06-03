Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  
  get "about-us", to: "about#index", as: :about

  root to: "main#index"
 
  get "up" => "rails/health#show", as: :rails_health_check

  
end
