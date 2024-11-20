defmodule ElixirXtdb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirXtdbWeb.Telemetry,
      ElixirXtdb.Repo,
      {DNSCluster, query: Application.get_env(:elixir_xtdb, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirXtdb.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ElixirXtdb.Finch},
      # Start a worker by calling: ElixirXtdb.Worker.start_link(arg)
      # {ElixirXtdb.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirXtdbWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirXtdb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirXtdbWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
