defmodule Proxy.Connection.Authentication do
  @moduledoc """
  Socks5 server authentification
  """

  require Logger

  def authenticate({client_socket} = context) do
    case client |> Networking.Protocol.Tcp.read_packet() do
      {:ok, packet} ->
        Logger.info "Got client side auth request"

        client |> Networking.Protocol.Tcp.write_packet(<<5, 0>>)

        {:ok, identify_connection(client)}
      {:error, reason} ->
        destroy_client(client)
        {:error, :abort}
    end
  end

  defp identify_connection(client) do
    case client |> Networking.Protocol.Tcp.read_packet() do
      {:ok, packet} ->
        {:ok, data} = parse_ip_data_from(packet, client)

        Logger.info "Creating tunnel for the client"

        {:ok, data}
      {:error, reason} ->
        destroy_client(client)
        {:error, reason}
    end
  end

  defp parse_ip_data_from(packet, client) do
    ip_data = Networking.Protocol.Socks.parse_destination({:ok, packet})

    case ip_data do
      {type, ip, port} ->
        {:ok, ip_data}
      {:error, :invalid_address_type} ->
        destroy_client(client)
    end
  end

  defp destroy_client(client) do
    :gen_tcp.close(client)
  end
end
