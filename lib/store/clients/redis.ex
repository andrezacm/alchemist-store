defmodule Store.Clients.Redis do
  alias Store.Clients.CacheHandler

  @behaviour CacheHandler
  @pool_size 5

  def child_spec(_args) do
    children =
      for i <- 0..(@pool_size - 1) do
        Supervisor.child_spec({Redix, name: :"redix_#{i}"}, id: {Redix, i})
      end

    %{
      id: RedisSupervisor,
      type: :supervisor,
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one]]}
    }
  end

  @impl CacheHandler
  def command(command) do
    Redix.command(:"redix_#{random_index()}", command)
  end

  defp random_index() do
    rem(System.unique_integer([:positive]), @pool_size)
  end
end
