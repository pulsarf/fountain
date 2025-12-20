defmodule Proxy.Tunnel.Connection do
  require Logger

  import Bitwise

  @doc """
  Start a new tunnel connection by creating the end socket.
  """
  @spec start(%Proxy.Connection.Context{}) :: {:ok, %Proxy.Connection.Context{}}
  def start(%Proxy.Connection.Context{
    ip_address_data: {destination_type, ip_buffer, port}
  } = context) do
    ip = Networking.Protocol.IP.format_ip(ip_buffer)

    socket = create_end_socket(ip, port)

    logging_proxy = &tunnel_proxy/2

    %{context | server_socket: socket, logging_proxy: logging_proxy}
  end

  @spec start({:error, atom}) :: {:error, atom}
  def start({:error, reason}) do
    Logger.error("Failed to start tunnel connection: #{inspect(reason)}")

    {:error, reason}
  end

  @doc """
  SOCKS5 packet modifier binding
  """
  @spec tunnel_proxy(atom, binary) :: binary
  defp tunnel_proxy(type, packet) do
    packet
  end

  @tcp_so_buffer 1 <<< 18

  @doc """
  Create a new end socket for the tunnel connection.
  """
  @spec create_end_socket(binary, integer) :: :gen_tcp.socket()
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
