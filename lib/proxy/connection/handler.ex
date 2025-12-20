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

  @spec authenticate(Proxy.Connection.Context.t()) :: {:ok, Proxy.Connection.Context.t()} | {:error, any()}
  defp authenticate(context) do
    Proxy.Connection.Authentication.authenticate(context)
  end

  @spec delegate(Proxy.Connection.Context.t()) :: {:ok, Proxy.Connection.Context.t()} | {:error, any()}
  defp delegate(context) do
    Proxy.Tunnel.delegate(context)
  end

  @spec start_connection(Proxy.Connection.Context.t()) :: {:ok, Proxy.Connection.Context.t()} | {:error, any()}
  defp start_connection(context) do
    Proxy.Tunnel.Connection.start(context)
  end

  @spec start_pipe(Proxy.Connection.Context.t()) :: {:ok, Proxy.Connection.Context.t()} | {:error, any()}
  defp start_pipe(context) do
    Networking.Protocol.Tcp.pipe(context)
  end
end
