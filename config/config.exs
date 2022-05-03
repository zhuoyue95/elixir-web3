import Config

# Configures Tesla
config :tesla, :adapter, {
  Tesla.Adapter.Finch,
  name: Web3.Finch, receive_timeout: 30_000
}
