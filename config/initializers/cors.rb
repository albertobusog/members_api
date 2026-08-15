# frozen_string_literal: true

# Allows the decoupled SPA (frontend/) to call the GraphQL API from another origin.
#
# Extra origins are configured per environment with FRONTEND_ORIGINS, a comma
# separated list of exact origins, e.g.
#   FRONTEND_ORIGINS="https://members-qa.vercel.app,https://members.vercel.app"
DEFAULT_FRONTEND_ORIGINS = [
  "http://localhost:5173",
  "http://127.0.0.1:5173",
  "http://localhost:4173",
  "http://127.0.0.1:4173"
].freeze

configured_origins = ENV.fetch("FRONTEND_ORIGINS", "").split(",").map(&:strip).reject(&:empty?)
allowed_origins = (DEFAULT_FRONTEND_ORIGINS + configured_origins).uniq

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*allowed_origins)

    resource "/graphql",
      headers: %w[Authorization Content-Type Accept],
      methods: [ :post, :options ],
      expose: [ "Authorization" ],
      max_age: 600

    resource "/health",
      headers: :any,
      methods: [ :get, :options ]
  end
end
