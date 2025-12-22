
defmodule Networking.Protocol.Tcp do
  @moduledoc """
  Utilities for TCP

  Mainly just packet segmentation, read, write, TTL modification
  """

  require Logger

  @doc """
  Reads a packet from a socket.
  """
  @spec read_packet(:gen_tcp.socket()) :: {:ok, binary()} | {:error, atom()}
  def read_packet(client) do
    :gen_tcp.recv(client, 0)
  end

  @doc """
  Writes a packet to a socket.
  """
  @spec write_packet(:gen_tcp.socket(), binary()) :: :ok | {:error, atom()}
  def write_packet(client, packet) do
    :gen_tcp.send(client, packet)
  end

  @doc """
  forward packets from client to socket and vice versa
  """
  @spec pipe(%Proxy.Connection.Context{}) :: %Proxy.Connection.Context{} | {:error, atom()}
  def pipe(%Proxy.Connection.Context{
    client_socket: client,
    server_socket: socket,
    logging_proxy: proxy
  } = context) do
    Logger.info "Piping the socket from client to server"

    tasks = [
      fn -> forward(client, socket, proxy, :client) end,
      fn -> forward(socket, client, proxy, :server) end
    ]

    Networking.Shared.Concurrent.race_tasks(tasks)

    context
  end

  @spec pipe({:error, atom()}) :: {:error, atom()}
  def pipe({_error, reason}) do
    Logger.error("Failed to pipe the socket from client to server: #{inspect(reason)}")

    {:error, reason}
  end

  @spec destroy_sockets([:gen_tcp.socket()]) :: :ok | {:error, atom()}
  defp destroy_sockets(sockets) do
    Enum.each(sockets, fn socket ->
      :gen_tcp.close(socket)
    end)
  end

  @spec forward(:gen_tcp.socket(), :gen_tcp.socket(), Proxy.t(), :client | :server) :: :ok | {:error, atom()}
  defp forward(from, to, proxy, way) do
    with {:ok, packet} <- read_packet(from),
      :ok <- write_packet(to, proxy.(way, packet)) do
      forward(from, to, proxy, way)
    else
      {:error, _} -> destroy_sockets([to, from])
    end
  end
end
