defmodule Store.RedixConsumer do
  use GenServer
  alias Store.Products

  # Client API

  def start_link() do
    GenServer.start_link(__MODULE__, "product", name: __MODULE__)
  end

  # Server API

  def init(channel) do
    pid = self()
    {:ok, pubsub} = Redix.PubSub.start_link()
    {:ok, ref} = Redix.PubSub.subscribe(pubsub, channel, pid)
    {:ok, {pid, channel, ref}}
  end

  def handle_info(
        {_pubsub, _pid, _ref, :message, %{channel: _channel, payload: "put:" <> payload}},
        state
      ) do
    {:ok, product_attrs} = Products.get_price_and_quantity(payload)

    product = Products.get_product!(payload)
    Products.update_product(product, product_attrs)

    {:noreply, state}
  end

  def handle_info(_message, state) do
    {:noreply, state}
  end
end
