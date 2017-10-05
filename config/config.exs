# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :lock_api, LockApiWeb.Endpoint,
  url: [host: "localhost"],
  #secret_key_base: "Ism09O0aQVFbc+O+L1Pm42yxuuurJH4EmhpjfVHWlWAHnMhYH36KRi6D3Gc+WoUb",
  render_errors: [view: LockApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: LockApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :simultaneous_access_lock,
  ttl: :timer.seconds(30),
  redix: "redis://localhost:6379/0"

config :alchemetrics, reporter_list: [
  [
    module: LockApi.Metrics.Reporters.Logstash,
    opts: [hostname: "logstash.video.dev.globoi.com", port: 8515]
  ]
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
