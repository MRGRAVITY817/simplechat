defmodule Simplechat.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SimplechatWeb.Telemetry,
      Simplechat.Repo,
      {Phoenix.PubSub, name: Simplechat.PubSub},
      SimplechatWeb.Presence,
      SimplechatWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Simplechat.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SimplechatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
