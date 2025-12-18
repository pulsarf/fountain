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
  ]
end
