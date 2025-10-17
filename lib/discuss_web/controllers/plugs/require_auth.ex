defmodule DiscussWeb.Plugs.RequireAuth do
  use DiscussWeb, :controller
  import Plug.Conn


  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns.user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page.")
      |> redirect(to: ~p"/") # redirect to homepage
      |> halt()
    end
  end
end
