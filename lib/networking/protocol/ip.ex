defmodule Networking.Protocol.IP do
  @doc """
  Format IP address as a tuple.
  """
  @spec format_ip(binary()) :: {integer, integer, integer, integer}
  def format_ip(<<a, b, c, d>>) do
    {a, b, c, d}
  end

  @spec format_ip(list()) :: {integer, integer, integer, integer}
  def format_ip([a, b, c, d]) do
    {a, b, c, d}
  end

  @spec format_ip(binary()) :: {integer, integer, integer, integer, integer, integer, integer, integer}
  def format_ip(<<a::16, b::16, c::16, d::16, e::16, f::16, g::16, h::16>>) do
    {a, b, c, d, e, f, g, h}
  end

  @doc """
  Check if a string is a valid IP address.

  TODO: Support IPv6 resolution.
  """
  @spec is_ip_string(String.t()) :: boolean()
  def is_ip_string(ip) do
    binary = Enum.map(String.split(ip, "."), &String.to_integer/1)

    try do
      case format_ip(binary) do
        {_, _, _, _} -> true
        {_, _, _, _, _, _, _, _} -> true
        _ -> false
      end
    rescue
      ArgumentError -> false
    end
  end

  @doc """
  Convert an IP address string to a tuple.
  """
  @spec to_tuple(String.t()) :: {integer, integer, integer, integer}
  def to_tuple(ip_string) do
    ip_string |> String.split(".") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
  end
end
