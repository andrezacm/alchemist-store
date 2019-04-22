defmodule StoreWeb.Router do
  use StoreWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug StoreWeb.Plugs.RequestLogger
  end

  scope "/api", StoreWeb do
    pipe_through :api
    resources "/products", ProductController
  end
end
