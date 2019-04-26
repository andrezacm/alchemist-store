defmodule Store.ProductsTest do
  use Store.DataCase
  use Store.MongoCase

  alias Store.Products

  describe "products" do
    alias Store.Products.Product

    @valid_attrs %{
      description: "some description",
      name: "some name",
      price: "120.5",
      quantity: 42,
      sku: "some sku"
    }
    @update_attrs %{
      description: "some updated description",
      name: "some updated name",
      price: "456.7",
      quantity: 43,
      sku: "some updated sku"
    }
    @invalid_attrs %{
      description: nil,
      name: nil,
      price: nil,
      quantity: nil,
      sku: nil
    }

    def product_fixture(attrs \\ %{}) do
      {:ok, product} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Products.create_product()

      product
    end

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Products.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Products.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      assert {:ok, %Product{} = product} = Products.create_product(@valid_attrs)
      assert product.description == "some description"
      assert product.name == "some name"
      assert product.price == 120.5
      assert product.quantity == 42
      assert product.sku == "some sku"
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Products.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      assert {:ok, product} = Products.update_product(product, @update_attrs)
      assert %Product{} = product
      assert product.description == "some updated description"
      assert product.name == "some updated name"
      assert product.price == 456.7
      assert product.quantity == 43
      assert product.sku == "some updated sku"
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Products.update_product(product, @invalid_attrs)
      assert product == Products.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Products.get_product!(product.id) end
    end

    test "fetch_product/1 fetches the product" do
      product = product_fixture()
      assert {:ok, ^product} = Products.fetch_product(product.id)
    end

    test "fetch_product/1 with id from inexistent product returns error not found" do
      product = product_fixture()
      assert {:ok, %Product{}} = Products.delete_product(product)
      assert {:error, :not_found} = Products.fetch_product(product.id)
    end

    ~S"""
    test "update_price_and_quantity/3 adds product's price and quantity to redis" do
      product = product_fixture()
      price = "5.0"
      quantity = "5"

      Products.update_price_and_quantity(product, price, quantity)

      assert {:ok, ^price} = Store.Redix.command(["GET", "#{product.id}:price"])
      assert {:ok, ^quantity} = Store.Redix.command(["GET", "#{product.id}:quantity"])
    end
    """

    test "get_price_and_quantity/3 gets price and quantity from redis" do
      product = product_fixture()
      price = "5.0"
      quantity = "5"

      Store.Redix.command(~w(SET #{product.id}:price #{price}))
      Store.Redix.command(~w(SET #{product.id}:quantity #{quantity}))

      assert {:ok, %{price: ^price, quantity: ^quantity}} =
               Products.get_price_and_quantity(product.id)
    end
  end
end
