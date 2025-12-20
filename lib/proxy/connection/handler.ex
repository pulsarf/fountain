defmodule Proxy.Connection.Handler do
  @doc """
  Handles the socks5 protocol flow
  """
  @spec handle_client(:inet.socket()) :: :ok
  def handle_client(client) do
    context = %Proxy.Connection.Context{client_socket: client}

    context
      |> authenticate()
      |> delegate()
      |> start_connection()
      |> start_pipe()
  end

  @doc """
  Authenticates the client connection.
  """
  @spec authenticate(Proxy.Connection.Context.t()) :: {:ok, Proxy.Connection.Context.t()} | {:error, any()}
  defp authenticate(context) do
    Proxy.Connection.Authentication.authenticate(context)
  end

  @doc """
  Delegates the client connection to the tunnel.
  """
  @spec delegate(Proxy.Connection.Context.t()) :: {:ok, Proxy.Connection.Context.t()} | {:error, any()}
  defp delegate(context) do
    Proxy.Tunnel.delegate(context)
  end

  @doc """
  Creates the end socket, so we can pipe the data
  """
  @spec start_connection(Proxy.Connection.Context.t()) :: {:ok, Proxy.Connection.Context.t()} | {:error, any()}
  defp start_connection(context) do
    Proxy.Tunnel.Connection.start(context)
  end

  @doc """
  Starts the pipe between the client and the end socket.
  """
  @spec start_pipe(Proxy.Connection.Context.t()) :: {:ok, Proxy.Connection.Context.t()} | {:error, any()}
  defp start_pipe(context) do
    Networking.Protocol.Tcp.pipe(context)
  end

  defp start_connection(error, _), do: error
  defp delegate(error, _), do: error
  defp start_pipe(error, _), do: error
end
