defmodule Store.RedixConsumer do
  use GenServer
  alias Store.Products

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    pid = self()
    {:ok, pubsub} = Redix.PubSub.start_link()
    {:ok, ref} = Redix.PubSub.subscribe(pubsub, "product", pid)
    {:ok, {pid, "product", ref}}
  end

  def handle_info({pubsub, pid, ref, :message, %{channel: channel, payload: "put:" <> payload}}, state) do
    IO.inspect("Updating #{payload}")

    product = Products.get_product!(payload)
    {:ok, product_attrs} = Products.get_price_and_quantity(product)
    Products.update_product(product, product_attrs)

    {:noreply, state}
  end

  def handle_info(message, state) do
    IO.inspect("OPA info")
    IO.inspect(message)
    {:noreply, state}
  end
end
