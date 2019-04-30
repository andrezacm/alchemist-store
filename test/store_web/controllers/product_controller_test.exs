defmodule StoreWeb.ProductControllerTest do
  use StoreWeb.ConnCase
  use Store.MongoCase

  alias Store.Products
  alias Store.Products.Product

  @create_attrs %{
    description: "some description",
    name: "some name",
    price: 120.5,
    quantity: 42,
    sku: "some sku"
  }
  @update_attrs %{
    description: "some updated description",
    name: "some updated name",
    price: 456.7,
    quantity: 43,
    sku: "some updated sku"
  }
  @invalid_attrs %{description: nil, name: nil, price: nil, quantity: nil, sku: nil}

  def fixture(:product) do
    {:ok, product} = Products.create_product(@create_attrs)
    product
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      conn = get(conn, product_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn} do
      conn = post(conn, product_path(conn, :create), product: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, product_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "description" => "some description",
               "name" => "some name",
               "price" => 120.5,
               "quantity" => 42,
               "sku" => "some sku"
             }
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, product_path(conn, :create), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    setup [:create_product]

    test "renders product when data is valid", %{conn: conn, product: %Product{id: id} = product} do
      conn = put(conn, product_path(conn, :update, product), product: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, product_path(conn, :show, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "description" => "some updated description",
               "name" => "some updated name",
               "price" => 456.7,
               "quantity" => 43,
               "sku" => "some updated sku"
             }
    end

    test "renders errors when data is invalid", %{conn: conn, product: product} do
      conn = put(conn, product_path(conn, :update, product), product: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete product" do
    setup [:create_product]

    test "deletes chosen product", %{conn: conn, product: product} do
      conn = delete(conn, product_path(conn, :delete, product))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, product_path(conn, :show, product))
      end)
    end
  end

  describe "updates product's price and quantity" do
    setup do
      client = Application.get_env(:store, :cache_client)
      client.start_link()

      create_product(nil)
    end

    test "stores new values in cache, send message to update product and renders product", %{
      conn: conn,
      product: %Product{id: id} = _product
    } do
      conn =
        put(
          conn,
          product_path(conn, :update_price_and_quantity, id),
          product: Map.take(@update_attrs, [:price, :quantity])
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]
    end
  end

  describe "get last product report" do
    setup [:create_product]

    test "renders last report file", %{conn: conn} do
      Store.Products.Report.generate()

      path = Application.get_env(:store, :upload_path) <> "/reports/products/"
      file = Path.wildcard(path <> "*.csv") |> List.first()

      on_exit(fn -> File.rm!(file) end)

      conn = get(conn, product_path(conn, :get_last_report))
      attachment = get_resp_header(conn, "content-disposition") |> List.first()

      assert response(conn, 200)
      assert get_resp_header(conn, "content-type") == ["text/csv"]
      assert attachment =~ ~r/attachment; filename=\".+\.csv\"/
    end

    test "renders not found when report was not generated", %{conn: conn} do
      conn = get(conn, product_path(conn, :get_last_report))

      assert response(conn, 404)
    end
  end

  defp create_product(_) do
    product = fixture(:product)
    {:ok, product: product}
  end
end
