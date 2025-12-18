defmodule Proxy.State do
  @moduledoc """
  The default state for the socks5 proxy, so we can have
  the socket and connection state shared between
  listeners
  """

  defstruct socket: nil, state: nil, port: 10000
end
