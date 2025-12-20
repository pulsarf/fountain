defmodule Networking.Protocol.IP do
  @doc """
  Format IP address as a tuple.
  """
  @spec format_ip(binary()) :: {integer, integer, integer, integer}
  def format_ip(<<a, b, c, d>>) do
    {a, b, c, d}
  end

  @spec format_ip(binary()) :: {integer, integer, integer, integer, integer, integer, integer, integer}
  def format_ip(<<a::16, b::16, c::16, d::16, e::16, f::16, g::16, h::16>>) do
    {a, b, c, d, e, f, g, h}
  end
end
