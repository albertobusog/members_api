require "active_support/core_ext/integer/time"

# QA mirrors production but keeps debugging affordances: verbose logging, no
# forced SSL redirect requirement toggle and optional eager loading.
Rails.application.configure do
  config.enable_reloading = false

  # Eager load by default, but allow turning it off to speed up QA boots.
  config.eager_load = ENV.fetch("RAILS_EAGER_LOAD", "true") == "true"

  config.consider_all_requests_local = ENV.fetch("RAILS_VERBOSE_ERRORS", "true") == "true"

  config.action_controller.perform_caching = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.hour.to_i}" }

  config.active_storage.service = :local

  config.assume_ssl = ENV.fetch("RAILS_ASSUME_SSL", "true") == "true"
  config.force_ssl = ENV.fetch("RAILS_FORCE_SSL", "true") == "true"

  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "debug")

  config.silence_healthcheck_path = "/up"

  config.active_support.report_deprecations = true

  # Free-tier hosting gives us a single Postgres database, so the Solid stack
  # (which expects dedicated cache/queue/cable databases) is not used here.
  config.cache_store = :memory_store
  config.active_job.queue_adapter = :async

  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "example.com") }

  config.i18n.fallbacks = true

  config.active_record.dump_schema_after_migration = false

  # Enable DNS rebinding protection; extra hosts come from RAILS_ALLOWED_HOSTS.
  config.hosts << ".onrender.com"
  ENV.fetch("RAILS_ALLOWED_HOSTS", "").split(",").map(&:strip).reject(&:empty?).each do |host|
    config.hosts << host
  end
  config.host_authorization = { exclude: ->(request) { request.path == "/up" || request.path == "/health" } }
end
