defmodule DiscussWeb.Router do
  alias DiscussWeb.Plugs.SetUser
  use DiscussWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_root_layout, html: {DiscussWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", DiscussWeb do
    pipe_through :browser

    # a route param called idp which can be any IDP your app supports
    get "/logout", AuthController, :logout
    get "/:idp", AuthController, :request
    get "/:idp/callback", AuthController, :callback
  end

  scope "/", DiscussWeb do
    pipe_through :browser

    get "/", TopicController, :index
    get "/topics/new", TopicController, :new
    post "/topics/new", TopicController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", DiscussWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:discuss, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DiscussWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
