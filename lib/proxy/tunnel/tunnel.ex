defmodule Proxy.Tunnel do
  require Logger

  def delegate(%Proxy.Connection.Context{
    client_socket: client_socket,
    ip_address_data: {destination_type, ip_buffer, port}
  } = context) do
    accept_client(client_socket, {destination_type, ip_buffer, port})

    context
  end

  defp accept_client(client, {destination_type, ip_buffer, port}) do
    Logger.info "Accepting client connection"

    ip = Networking.Protocol.IP.format_ip(ip_buffer)

    Networking.Protocol.Tcp.write_packet(
      client,
      make_success_response(destination_type, ip_buffer, port)
    )
  end

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
