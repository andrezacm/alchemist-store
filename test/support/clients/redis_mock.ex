defmodule Store.Clients.RedisMock do
  alias Store.Clients.CacheHandler
  use GenServer

  @behaviour CacheHandler

  ## Client API

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl CacheHandler
  def command(command) do
    GenServer.call(__MODULE__, command)
  end

  ## Server API

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(["SET", key, value], _from, cache) do
    {:reply, {:ok, "OK"}, Map.put(cache, key, value)}
  end

  @impl true
  def handle_call(["GET", key], _from, cache) do
    {:reply, Map.fetch(cache, key), cache}
  end

  @impl true
  def handle_call(["PUBLISH", _channel, _message], _from, cache) do
    {:reply, {:ok, 1}, cache}
  end
end
