defmodule Store.RedixConsumerTest do
  use ExUnit.Case, async: true
  alias Store.{Products, RedixConsumer, Products.Product}

  setup do
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

    Store.Redix.command(~w(SET #{product_id}:price #{price}))
    Store.Redix.command(~w(SET #{product_id}:quantity #{quantity}))

    RedixConsumer.handle_info(
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
