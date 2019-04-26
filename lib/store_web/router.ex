defmodule StoreWeb.Router do
  use StoreWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(StoreWeb.Plugs.RequestLogger)
  end

  scope "/api", StoreWeb do
    pipe_through(:api)
    resources("/products", ProductController)

    scope "/product" do
      get("/generate_report", ProductController, :generate_report)
      get("/last_report", ProductController, :get_last_report)
    end
  end
end
