defmodule Store.Products.CachePublisherTest do
  use ExUnit.Case, async: true
  alias Store.Products.CachePublisher

  setup do
    client = Application.get_env(:store, :cache_client)
    client.start_link()

    {:ok, client: client}
  end

  test "set_price/2 and get_price/1" do
    product_id = "P_ID"
    price = "2.5"

    assert {:ok, "OK"} = CachePublisher.set_price(product_id, price)
    assert {:ok, ^price} = CachePublisher.get_price(product_id)
  end

  test "set_quantity/2 and get_quantity/1" do
    product_id = "P_ID"
    quantity = "5"

    assert {:ok, "OK"} = CachePublisher.set_quantity(product_id, quantity)
    assert {:ok, ^quantity} = CachePublisher.get_quantity(product_id)
  end
end
