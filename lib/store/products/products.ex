defmodule Store.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false

  alias Store.{Repo, Products.Product, Products.CachePublisher}

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product.

  Raises if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

  """
  def get_product!(id) do
    Repo.get!(Product, id)
  end

  @doc """
  Fetchs a single product.

  ## Examples

      iex> fetch_product(123)
      {:ok, %Product{}}

      iex> fetch_product(123)
      {:error, ...}

  """
  def fetch_product(id) do
    case Repo.get(Product, id) do
      %Product{} = product -> {:ok, product}
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, ...}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, ...}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, ...}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Updates product's price and quantity, storing the new values to cache.
  """
  def update_price_and_quantity(product_id, price, quantity) do
    {:ok, "OK"} = CachePublisher.set_price(product_id, price)
    {:ok, "OK"} = CachePublisher.set_quantity(product_id, quantity)
    {:ok, _} = CachePublisher.publish(product_id)

    {:ok, %{price: price, quantity: quantity}}
  end

  @doc """
  Fetchs product's price and quantity stored in cache.
  """
  def get_price_and_quantity(product_id) do
    {:ok, price} = CachePublisher.get_price(product_id)
    {:ok, quantity} = CachePublisher.get_quantity(product_id)

    {:ok, %{price: price, quantity: quantity}}
  end
end
