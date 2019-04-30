defmodule Store.Products.CachePublisher do
  @cache_client Application.get_env(:store, :cache_client)

  @valid_attrs [:price, :quantity]

  @valid_attrs
  |> Enum.each(fn attr ->
    def unquote(:"get_#{attr}")(product_id) do
      @cache_client.command(~w(GET #{product_id}:#{unquote(attr)}))
    end
  end)

  @valid_attrs
  |> Enum.each(fn attr ->
    def unquote(:"set_#{attr}")(product_id, value) do
      @cache_client.command(~w(SET #{product_id}:#{unquote(attr)} #{value}))
    end
  end)

  def publish(product_id) do
    @cache_client.command(~w(PUBLISH product put:#{product_id}))
  end
end
