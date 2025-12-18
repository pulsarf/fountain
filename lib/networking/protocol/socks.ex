defmodule Networking.Protocol.Socks do
  @moduledoc """
  Utilities for the socks5 proxy

  Gladly the parser logic is way simpler than in the Rust waterfall
  """

  def parse_destination({:ok, packet}) when is_binary(packet) and byte_size(packet) > 5 do
    <<_::binary-size(3), destination_type, domain_length>> = binary_part(packet, 0, 5)

    case destination_type do
      0x01 when byte_size(packet) >= 10 -> {
        :ipv4,
        binary_part(packet, 4, 4),
        Utilities.Binary.read_u16(binary_part(packet, 8, 2))
      }

      0x03 when byte_size(packet) >= 5 + domain_length + 2 -> {
        :nameserver,
        Networking.Dns.Https.resolve(binary_part(packet, 5, domain_length)),
        443
      }

      0x04 when byte_size(packet) >= 22 -> {
        :ipv6,
        binary_part(packet, 4, 16),
        Utilities.Binary.read_u16(binary_part(packet, 20, 2))
      }

      _ -> {:error, :invalid_address_type}
    end
  end
end
