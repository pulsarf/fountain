defmodule Proxy.Connection.Context do
  @moduledoc """
  A connection descriptor, with a state machine
  """

  defstruct [
    :client_socket,
    :server_socket,
    :ip_address_data,
    :ip_buffer,
    :port,
    :connection_method,
    :state,
    :logging_proxy
  ]

  @type t :: %Proxy.Connection.Context{
    client_socket: :gen_tcp.socket() | nil,
    server_socket: :gen_tcp.socket() | nil,
    ip_address_data: {integer(), term(), integer()} | nil,
    ip_buffer: list() | nil,
    port: integer() | nil,
    connection_method: atom() | nil,
    state: atom() | nil,
    logging_proxy: function() | nil
  }
end
