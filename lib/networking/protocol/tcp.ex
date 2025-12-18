
defmodule Networking.Protocol.Tcp do
  @moduledoc """
  Utilities for TCP

  Mainly just packet segmentation, read, write, TTL modification
  """

  require Logger

  def read_packet(client) do
    :gen_tcp.recv(client, 0)
  end

  def write_packet(client, packet) do
    :gen_tcp.send(client, packet)
  end

  @doc """
  forward packets from client to socket and vice versa
  """
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

    Utilities.Concurrent.race_tasks(tasks)

    context
  end

  defp destroy_sockets(sockets) do
    Enum.each(sockets, fn socket ->
      :gen_tcp.close(socket)
    end)
  end

  defp forward(from, to, proxy, way) do
    case read_packet(from) do
      {:ok, packet} ->
        write_packet(to, proxy.(way, packet))
        forward(from, to, proxy, way)
      {:error, reason} ->
        destroy_sockets([to, from])
        {:close}
    end
  end
end
