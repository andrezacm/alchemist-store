defmodule Store.Clients.CacheHandler do
  @callback command([String.t()]) :: {:ok, term} | {:error, String.t()}
end
