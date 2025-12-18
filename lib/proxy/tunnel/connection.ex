defmodule Proxy.Tunnel.Connection do
  require Logger

  import Bitwise

  def start(%Proxy.Connection.Context{
    ip_address_data: {destination_type, ip_buffer, port}
  } = context) do
    ip = Networking.Protocol.IP.format_ip(ip_buffer)

    socket = create_end_socket(ip, port)

    logging_proxy = &tunnel_proxy/2

    %{context | server_socket: socket, logging_proxy: logging_proxy}
  end

  defp tunnel_proxy(type, packet) do
    packet
  end

  @tcp_so_buffer 1 <<< 18

  defp create_end_socket(ip_buffer, port) do
    {:ok, socket} = :gen_tcp.connect(ip_buffer, port, [
        :binary,
        active: false,
        nodelay: true,
        buffer: @tcp_so_buffer
      ]
    )

    socket
  end
end
