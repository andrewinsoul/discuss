defmodule DiscussWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller

  use Phoenix.VerifiedRoutes,
    endpoint: DiscussWeb.Endpoint,
    router: DiscussWeb.Router,
    statics: DiscussWeb.static_paths()

  def init(_params) do
  end

  def call(conn, _params) do
    if conn.assigns[:user] do
      conn
    else
      conn
      |> put_flash(:error, "You need to be logged in")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
