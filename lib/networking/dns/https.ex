defmodule Networking.Dns.Https do
  require Logger

  @doc """
  Resolve a domain name to an IP address.

  Supports caching.
  """
  @spec resolve(binary) :: binary
  def resolve(buffer) do
    if not check_if_table_exists() do
      make_table()
    end

    lookup(buffer)
  end

  defp lookup(buffer) do
    case :ets.lookup(:dns_cache, buffer) do
      [{^buffer, ip}] ->
        Logger.debug "Using cached IP address for #{buffer}"

        :erlang.list_to_binary(Tuple.to_list(ip))
      _ ->
        {:ok, {:hostent, _, _, :inet, _, [ip | _]}} = :inet.gethostbyname(String.to_charlist(buffer))

        :ets.insert(:dns_cache, {buffer, ip})

        :erlang.list_to_binary(Tuple.to_list(ip))
    end
  end

  defp check_if_table_exists do
    case :ets.info(:dns_cache) do
      :undefined ->
        false
      _ ->
        true
    end
  end

  defp make_table() do
    Logger.info "Building DNS cache"

    :ets.new(:dns_cache, [:set, :public, :named_table])
  end
end
