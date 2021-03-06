use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :store, StoreWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :store, Store.Repo,
  adapter: Mongo.Ecto,
  database: "store_test",
  hostname: "localhost"

config :store, :upload_path, Path.expand("../test/support/uploads", __DIR__)

config :store, :cache_client, Store.Clients.RedisMock
