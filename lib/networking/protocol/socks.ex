defmodule Networking.Protocol.Socks do
  @moduledoc """
  Utilities for the socks5 proxy

  Gladly the parser logic is way simpler than in the Rust waterfall
  """

  @ipv4 0x01
  @ipv6 0x04
  @nameserver 0x03

  @ip_address_start 4
  @nameserver_start 5
  @ipv4_length 4
  @ipv6_length 16

  @https_default_port 443

  @header_length 5
  @header_start 0

  @ipv4_port_start 8
  @ipv6_port_start 20
  @port_length 2

  @min_ipv4_request_length 10
  @min_ipv6_request_length 22
  @min_nameserver_request_length 7

  @doc """
  Parse the server address from SOCKS5 connection request.
  """
  @spec parse_destination({:ok, binary()}) :: {:ok, {atom(), binary(), integer()}} | {:error, atom()}
  def parse_destination({:ok, packet}) when is_binary(packet) and byte_size(packet) > 5 do
    <<_::binary-size(3), destination_type, domain_length>> = binary_part(
      packet,
      @header_start,
      @header_length
    )

    case destination_type do
      @ipv4 -> parse_ipv4(packet)
      @nameserver -> parse_nameserver(packet, domain_length)
      @ipv6 -> parse_ipv6(packet)
      _ -> {:error, :invalid_address_type}
    end
  end

  @doc """
  Parse IPv4 address from SOCKS5 connection request.
  """
  @spec parse_ipv4(binary) :: {atom, binary, integer}
  defp parse_ipv4(packet) when byte_size(packet) >= @min_ipv4_request_length do
    {
      :ipv4,
      binary_part(packet, @ip_address_start, @ipv4_length),
      Utilities.Binary.read_u16(
        binary_part(packet, @ipv4_port_start, @port_length)
      )
    }
  end

  @doc """
  Parse domain name from SOCKS5 connection request.
  """
  @spec parse_nameserver(binary, integer) :: {atom, binary, integer}
  defp parse_nameserver(packet, domain_length) when byte_size(packet) >= @min_nameserver_request_length + domain_length do
    {
      :nameserver,
      Networking.Dns.Https.resolve(
        binary_part(packet, @nameserver_start, domain_length)
      ),
      @https_default_port
    }
  end

  @doc """
  Parse IPv6 address from SOCKS5 connection request.
  """
  @spec parse_ipv6(binary) :: {atom, binary, integer}
  defp parse_ipv6(packet) when byte_size(packet) >= @min_ipv6_request_length do
    {
      :ipv6,
      binary_part(packet, @ip_address_start, @ipv6_length),
      Utilities.Binary.read_u16(
        binary_part(packet, @ipv6_port_start, @port_length)
      )
    }
  end

  defp parse_ipv4(_), do: {:error, :packet_too_short}
  defp parse_ipv6(_), do: {:error, :packet_too_short}
  defp parse_nameserver(_, _), do: {:error, :packet_too_short}
end
