defmodule Store.Products.CacheConsumerTest do
  use ExUnit.Case, async: true
  alias Store.{Products, Products.CacheConsumer, Products.Product, Products.CachePublisher}

  setup do
    client = Application.get_env(:store, :cache_client)
    client.start_link()

    pid = self()
    channel = "test_channel"
    {:ok, pubsub} = Redix.PubSub.start_link()
    {:ok, ref} = Redix.PubSub.subscribe(pubsub, channel, pid)

    {:ok, product} =
      Products.create_product(%{
        description: "some description",
        name: "some name",
        price: "120.5",
        quantity: 42,
        sku: "some sku"
      })

    {:ok, pid: pid, channel: channel, ref: ref, pubsub: pubsub, product_id: product.id}
  end

  test "updates product", meta do
    price = 5.0
    quantity = 5
    product_id = meta[:product_id]

    CachePublisher.set_price(product_id, price)
    CachePublisher.set_quantity(product_id, quantity)

    CacheConsumer.handle_info(
      {
        meta[:pubsub],
        meta[:pid],
        meta[:ref],
        :message,
        %{channel: meta[:channel], payload: "put:#{product_id}"}
      },
      {meta[:pid], meta[:channel], meta[:ref]}
    )

    assert %Product{price: ^price, quantity: ^quantity} = Products.get_product!(product_id)
  end
end
