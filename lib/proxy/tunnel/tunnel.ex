defmodule Proxy.Tunnel do
  require Logger

  @spec delegate(%Proxy.Connection.Context{}) :: %Proxy.Connection.Context{}
  def delegate(%Proxy.Connection.Context{
    client_socket: client_socket,
    ip_address_data: {destination_type, ip_buffer, port}
  } = context) do
    accept_client(client_socket, {destination_type, ip_buffer, port})

    context
  end

  @spec delegate({:error, atom()}) :: {:error, atom()}
  def delegate({:error, reason}) do
    Logger.error "Error delegating tunnel: #{inspect(reason)}"

    {:error, reason}
  end

  @spec accept_client(:gen_tcp.socket(), {atom(), binary(), integer()}) :: {:ok, :gen_tcp.socket()}
  defp accept_client(client, {destination_type, ip_buffer, port}) do
    Logger.info "Accepting client connection"

    Networking.Protocol.Tcp.write_packet(
      client,
      make_success_response(destination_type, ip_buffer, port)
    )
  end

  @spec make_success_response(atom(), binary(), integer()) :: binary()
  defp make_success_response(destination_type, ip_buffer, port) do
    port_bin = <<port::16>>

    destination_type_bin = case destination_type do
      :ipv4 -> <<0x01>>
      :ipv6 -> <<0x04>>
      :nameserver -> <<0x03, byte_size(ip_buffer)>>
    end

    <<5, 0, 0>> <> destination_type_bin <> ip_buffer <> port_bin
  end
end
