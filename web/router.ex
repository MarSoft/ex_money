defmodule ExMoney.Router do
  use ExMoney.Web, :router

  pipeline :browser_session do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :saltedge_api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
  end

  pipeline :graphql do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource
    plug ExMoney.Plugs.GraphqlContext
  end

  scope "/", ExMoney do
    pipe_through [:browser, :browser_session]

    get "/", DashboardController, :overview

    get "/login", SessionController, :new, as: :login
    get "/setup/new", SetupController, :new
    post "/setup/complete", SetupController, :complete
    post "/login", SessionController, :create, as: :login
    delete "/logout", SessionController, :delete, as: :logout
    get "/logout", SessionController, :delete, as: :logout

    scope "/dashboard" do
      get "/", DashboardController, :overview
      get "/overview", DashboardController, :overview
    end

    scope "/settings", Settings, as: :settings do
      get "/user", UserController, :edit
      put "/user", UserController, :update
      resources "/accounts", AccountController
      get "/categories/sync", CategoryController, :sync
      resources "/categories", CategoryController
      resources "/rules", RuleController
      resources "/logins", LoginController, only: [:index, :delete, :show]
    end

    resources "/transactions", TransactionController
  end

  scope "/m", ExMoney.Mobile, as: :mobile do
    pipe_through [:browser, :browser_session]

    get "/", StartController, :index
    get "/dashboard", DashboardController, :overview
    get "/overview", DashboardController, :overview
    get "/login", SessionController, :new, as: :login
    get "/logged_in", SessionController, :exist, as: :logged_in
    post "/login", SessionController, :create, as: :login
    get "/accounts/:id/refresh", AccountController, :refresh
    get "/accounts/:id/expenses", AccountController, :expenses
    get "/accounts/:id/income", AccountController, :income
    resources "/accounts", AccountController, only: [:show]
    resources "/transactions", TransactionController
  end

  scope "/saltedge", as: :saltedge do
    pipe_through [:browser, :browser_session]

    scope "/logins" do
      get "/new", ExMoney.Saltedge.LoginController, :new
      get "/:id/sync", ExMoney.Saltedge.LoginController, :sync
    end

    scope "/accounts" do
      get "/sync", ExMoney.Saltedge.AccountController, :sync
    end

  end

  scope "/callbacks", as: :callbacks do
    pipe_through [:saltedge_api, :browser_session]

    post "/success", CallbacksController, :success, as: :success
    post "/failure", CallbacksController, :failure, as: :failure
    post "/notify", CallbacksController, :notify, as: :notify
    post "/interactive", CallbacksController, :interactive, as: :interactive
    post "/destroy", CallbacksController, :destroy, as: :destroy
  end

  scope "/api/v1", ExMoney.Api.V1, as: :api do
    pipe_through [:api]
    get "/session/relogin", SessionController, :relogin
  end

  scope "/api/v2" do
    pipe_through [:graphql]

    forward "/", Absinthe.Plug, schema: ExMoney.Schema
  end
end
