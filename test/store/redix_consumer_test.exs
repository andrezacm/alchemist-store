defmodule Store.ReddixConsumerTest do
  use ExUnit.Case, async: true
  alias Store.{Products, RedixConsumer, Products.Product}

  setup do
    pid = self()
    channel = "test_channel"
    {:ok, pubsub} = Redix.PubSub.start_link()
    {:ok, ref} = Redix.PubSub.subscribe(pubsub, channel, pid)
   
    {:ok,
      pid: pid,
      channel: channel,
      ref: ref,
      pubsub: pubsub
    }
  end

  test "updates product", meta do
    {:ok, product} = Products.create_product(%{description: "some description", name: "some name", price: "120.5", quantity: 42, sku: "some sku"})

    price = 5.0
    quantity = 5

    Store.Redix.command(~w(SET #{product.id}:price #{price}))
    Store.Redix.command(~w(SET #{product.id}:quantity #{quantity}))

    RedixConsumer.handle_info(
      {
        meta[:pubsub],
        meta[:pid],
        meta[:ref],
        :message,
        %{channel: meta[:channel], payload: "put:#{product.id}"}
      }, 
      {meta[:pid], meta[:channel], meta[:ref]}
    )

    assert %Product{price: ^price, quantity: ^quantity} = Products.get_product!(product.id)
  end
end
