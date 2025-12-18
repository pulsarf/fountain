defmodule Proxy.Connection.Handler do
  def handle_client(client) do
    context = %Context{client_socket: client}

    context
      |> authenticate()
      |> delegate()
      |> start_connection()
      |> start_pipe()
  end

  defp authenticate(context) do
    Proxy.Auth.authenticate(context)
  end

  defp delegate({:error, :abort} = error, _), do: error
  defp delegate({:ok, auth}, client) do
    Proxy.Tunnel.delegate(auth, client)
  end

  defp start_connection({:ok, tunnel}, client) do
    Proxy.Tunnel.Connection.start(tunnel, client)
  end
  defp start_connection({:error, _}, _), do: {:error, :abort}

  defp start_pipe({:ok, {socket, logging_proxy}}, client) do
    Networking.Protocol.Tcp.pipe({socket, logging_proxy}, client)
  end
  defp start_pipe({:error, _}, _), do: {:error, :abort}
end
