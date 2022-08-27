defmodule Fox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @mix_env Mix.env()

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fox.Supervisor]
    Supervisor.start_link(children(@mix_env), opts)
  end

  defp children(:test = _env) do
    [
      # Start the Ecto repository
      Fox.Repo,
      # Start the Telemetry supervisor
      FoxWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Fox.PubSub},
      # Start the Endpoint (http/https)
      FoxWeb.Endpoint
    ]
  end

  defp children(_env) do
    [
      # Start the Ecto repository
      Fox.Repo,
      # Services
      Fox.Nordigen.ClientServer,
      # Start the Telemetry supervisor
      FoxWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Fox.PubSub},
      # Start the Endpoint (http/https)
      FoxWeb.Endpoint
    ]
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FoxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
