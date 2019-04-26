defmodule Store.Products.Report do
  @moduledoc """
  The Products report.
  """

  use Task

  alias Store.{Repo, Products, Products.Product}

  @upload_path Application.get_env(:store, :upload_path) <> "/reports/products/"

  @doc false
  def start_link() do
    Task.start_link(__MODULE__, :generate, [])
  end

  @doc """
  Generates CSV file with products report.
  """
  def generate do
    file = File.open!(get_file_name(), [:write, :utf8])

    Products.list_products()
    |> CSV.encode(headers: Repo.list_fields(%Product{}))
    |> Enum.each(&IO.write(file, &1))
  end

  @doc """
  Get last report.
  """
  def get_last do
    report =
      Path.wildcard(@upload_path <> "*.csv")
      |> Enum.sort()
      |> List.last()

    if report == nil do
      {:error, :not_found}
    else
      {:ok, report}
    end
  end

  defp get_file_name do
    time = DateTime.utc_now() |> DateTime.to_string()
    "#{@upload_path}#{time}.csv"
  end
end
