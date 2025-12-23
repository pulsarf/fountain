defmodule Networking.Dns.Https do
  require Logger

  require HTTPoison
  require Jason

  @default_servers [
    "https://dns.google/resolve",
  ]

  @spec get_request_url(String.t()) :: String.t()
  defp get_request_url(nameserver) do
    random_string = Padding.generate_padding()

    "?name=#{nameserver}&edns_client_subnet=0.0.0.0/0&random_padding=#{random_string}"
  end

  @spec make_dns_requests(String.t()) :: [Task.t()]
  defp make_dns_requests(request_url) do
    tasks = Enum.map(@default_servers, fn server -> "#{server}#{request_url}" end)
      |> Enum.map(&Task.async(fn -> HTTPoison.get(&1) end))

    with [{_, {:ok, {:ok, %{body: body}}}}] <- Task.yield_many(tasks),
      {:ok, %{"Answer" => answers}} <- Jason.decode(body) do
      answers
    else
      _ -> :error
    end
  end

  @spec find_ip_data([map]) :: String.t()
  defp find_ip_data(answers) do
    Enum.find(answers, &Networking.Protocol.IP.is_ip_string(&1["data"]))["data"]
  end

  @spec native_dns_lookup(String.t()) :: {integer, integer, integer, integer}
  defp native_dns_lookup(nameserver) do
    case :inet.gethostbyname(nameserver) do
      {:ok, {:hostent, _, _, :inet, _, [ip | _]}} -> ip
      _ -> :error
    end
  end

  @doc """
  Look up an IP address for a given domain name using HTTPS DNS.
  """
  @spec lookup(String.t()) :: {integer, integer, integer, integer}
  def lookup(nameserver) do
    try do
      request_url = get_request_url(nameserver)
      answers = make_dns_requests(request_url)

      ip = find_ip_data(answers)

      Networking.Protocol.IP.to_tuple(ip)
    rescue
      _ -> Logger.warning "Falling back to native system DNS"
        native_dns_lookup(nameserver)
    end
  end

  @doc """
  Resolve a domain name to an IP address.

  Supports caching.
  """
  @spec resolve(binary) :: binary
  def resolve(buffer) do
    if not check_if_table_exists() do
      make_table()
    end

    lookup_or_retrieve_cache(buffer)
  end

  @spec lookup_or_retrieve_cache(binary) :: binary
  defp lookup_or_retrieve_cache(buffer) do
    case :ets.lookup(:dns_cache, buffer) do
      [{^buffer, ip}] ->
        Logger.debug "Using cached IP address for #{buffer}"

        :erlang.list_to_binary(Tuple.to_list(ip))
      _ ->
        Logger.debug "Doing lookup for #{buffer}"

        ip = lookup(String.to_charlist(buffer))

        :ets.insert(:dns_cache, {buffer, ip})

        :erlang.list_to_binary(Tuple.to_list(ip))
    end
  end

  @spec check_if_table_exists :: boolean
  defp check_if_table_exists do
    case :ets.info(:dns_cache) do
      :undefined ->
        false
      _ ->
        true
    end
  end

  @spec make_table :: :ok
  defp make_table() do
    Logger.info "Building DNS cache"

    :ets.new(:dns_cache, [:set, :public, :named_table])
  end
end
