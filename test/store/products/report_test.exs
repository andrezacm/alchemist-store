defmodule Store.Products.ReportTest do
  use Store.DataCase
  use Store.MongoCase

  alias Store.{Products.Report, Products.Product, Products, Repo}

  def product_fixture(attrs \\ %{}) do
    {:ok, product} = Products.create_product(attrs)
    product
  end

  def create_products do
    for n <- 1..3 do
      product_fixture(%{name: "Product #{n}", sku: "sku#{n}"})
    end
  end

  setup do
    {:ok, products: create_products()}
  end

  test "generates csv file with products report", %{products: products} do
    Report.generate()

    path = Application.get_env(:store, :upload_path) <> "/reports/products/"
    file = Path.wildcard(path <> "*.csv") |> List.first()

    on_exit(fn -> File.rm!(file) end)

    report = File.stream!(file) |> CSV.decode!(headers: true) |> MapSet.new()

    expected =
      products
      |> Enum.map(&Map.take(&1, Repo.list_fields(%Product{})))
      |> Enum.map(&Map.new(&1, fn {k, v} -> {"#{k}", "#{v}"} end))
      |> MapSet.new()

    assert true = MapSet.equal?(report, expected)
  end

  describe "get last report" do
    test "returns last report generated" do
      for _n <- 0..3 do
        Report.generate()
      end

      path = Application.get_env(:store, :upload_path) <> "/reports/products/"
      files = Path.wildcard(path <> "*.csv") |> Enum.sort()

      on_exit(fn -> Enum.each(files, &File.rm!(&1)) end)

      assert {:ok, List.last(files)} == Report.get_last()
    end

    test "returns error when there is no report" do
      assert {:error, :not_found} == Report.get_last()
    end
  end
end
