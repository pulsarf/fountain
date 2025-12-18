defmodule Proxy.Connection.Handler do
  def handle_client(client) do
    context = %Proxy.Connection.Context{client_socket: client}

    context
      |> authenticate()
      |> delegate()
      |> start_connection()
      |> start_pipe()
  end

  defp authenticate(context) do
    Proxy.Connection.Authentication.authenticate(context)
  end

  defp delegate(context) do
    Proxy.Tunnel.delegate(context)
  end

  defp start_connection(context) do
    Proxy.Tunnel.Connection.start(context)
  end

  defp start_pipe(context) do
    Networking.Protocol.Tcp.pipe(context)
  end

  defp start_connection(error, _), do: error
  defp delegate(error, _), do: error
  defp start_pipe(error, _), do: error
end
