defmodule Project do
  @moduledoc """
  Waterfall entry point
  """

  use Application

  require Logger

  @socks5_proxy_port 10000

  def start(_type, _args) do
    children = [
      {Proxy.Server, [:start_link, @socks5_proxy_port]}
    ]

    opts = [strategy: :one_for_one, name: Proxy.Supervisor]

    Logger.info("WaterfallRecode is running on socks5://localhost:10000")

    Supervisor.start_link(children, opts)
  end
end
