defmodule Store.MongoCase do
  use ExUnit.CaseTemplate

  setup do
    Mongo.Ecto.truncate(Store.Repo)
    :ok
  end
end
