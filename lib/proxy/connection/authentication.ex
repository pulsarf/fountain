defmodule Proxy.Connection.Authentication do
  @moduledoc """
  Socks5 server authentification
  """

  require Logger

  @doc """
  Authenticates the client and identifies the connection.
  """
  @spec authenticate(Proxy.Connection.Context.t()) :: {:ok, Proxy.Connection.Context.t()} | {:error, any()}
  def authenticate(%Proxy.Connection.Context{
    client_socket: client_socket
  } = context) do
    with {_, packet} <- Networking.Protocol.Tcp.read_packet(client_socket),
      :ok <- Networking.Protocol.Tcp.write_packet(client_socket, <<5, 0>>) do
      identify_connection(context)
    else
      {:error, reason} ->
        destroy_client(client_socket)
        {:error, reason}
    end
  end

  @doc """
  Identifies the connection by reading the destination address from the client.
  """
  @spec identify_connection(Proxy.Connection.Context.t()) :: {:ok, Proxy.Connection.Context.t()} | {:error, any()}
  defp identify_connection(%Proxy.Connection.Context{client_socket: client_socket} = context) do
    with {:ok, packet} <- Networking.Protocol.Tcp.read_packet(client_socket),
         {:ok, data} <- parse_ip_data_from(packet, client_socket) do
      %{context | ip_address_data: data}
    else
      {:error, reason} ->
        destroy_client(client_socket)
        {:error, reason}
    end
  end

  @doc """
  Parses the IP data from the client's packet.
  """
  @spec parse_ip_data_from(binary(), :inet.socket()) :: {:ok, {integer(), binary(), integer()}} | {:error, any()}
  defp parse_ip_data_from(packet, client) do
    ip_data = Networking.Protocol.Socks.parse_destination({:ok, packet})

    case ip_data do
      {type, ip, port} ->
        {:ok, ip_data}
      {:error, :invalid_address_type} ->
        destroy_client(client)
    end
  end

  @doc """
  Destroys the client connection.
  """
  @spec destroy_client(:inet.socket()) :: :ok
  defp destroy_client(client) do
    :gen_tcp.close(client)
  end
end
