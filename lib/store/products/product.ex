defmodule Store.Products.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias Store.Products.Product

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "products" do
    field(:name)
    field(:sku)
    field(:description)
    field(:quantity, :integer, default: 0)
    field(:price, :float, default: 0.0)
  end

  @doc false
  def changeset(%Product{} = product, attrs) do
    product
    |> cast(attrs, [:name, :sku, :description, :quantity, :price])
    |> validate_required([:name, :sku])
  end
end
