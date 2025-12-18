defmodule Networking.Protocol.IP do
  def format_ip(<<a, b, c, d>>) do
    {a, b, c, d}
  end

  def format_ip(<<a::16, b::16, c::16, d::16, e::16, f::16, g::16, h::16>>) do
    {a, b, c, d, e, f, g, h}
  end
end
