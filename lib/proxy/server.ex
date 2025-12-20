defmodule Proxy.Server do
  use GenServer

  require Logger

  @doc """
  Start the proxy server.
  """
  @spec init(%Proxy.State{}) :: {:ok, %Proxy.State{}}
  def init(state) do
    Logger.info "Waterfall server load at port #{state.port}"

    {:ok, socket} = :gen_tcp.listen(state.port, [:binary, active: false])

    send(self(), :accept)

    {:ok, %{state | socket: socket}}
  end

  @doc """
  Initialize Genserver.
  """
  @spec start_link(any()) :: {:ok, pid}
  def start_link(_) do
    GenServer.start_link(__MODULE__, %Proxy.State{port: 10000}, name: __MODULE__)
  end

  @doc """
  Handle incoming client connections.
  """
  @spec handle_info(:accept, %Proxy.State{}) :: {:noreply, %Proxy.State{}}
  def handle_info(:accept, %{socket: socket} = state) do
    {:ok, client} = :gen_tcp.accept(socket)

    Proxy.Connection.Handler.handle_client(client)

    send(self(), :accept)

    {:noreply, state}
  end
end
