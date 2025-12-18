defmodule Networking.Dns.Https do
  def resolve(buffer) do
    {:ok, {:hostent, _, _, :inet, _, [ip | _]}} = :inet.gethostbyname(String.to_charlist(buffer))

    :erlang.list_to_binary(Tuple.to_list(ip))
  end
end
