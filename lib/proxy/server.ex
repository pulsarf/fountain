defmodule Proxy.Server do
  use GenServer

  require Logger

  def init(state) do
    Logger.info "Waterfall server load at port #{state.port}"

    {:ok, socket} = :gen_tcp.listen(state.port, [:binary, active: false])

    send(self(), :accept)

    {:ok, %{state | socket: socket}}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %Proxy.State{port: 10000}, name: __MODULE__)
  end

  def handle_info(:accept, %{socket: socket} = state) do
    {:ok, client} = :gen_tcp.accept(socket)

    Proxy.Connection.Handler.handle_client(client)

    send(self(), :accept)

    {:noreply, state}
  end
end
