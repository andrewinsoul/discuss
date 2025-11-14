defmodule DiscussWeb.AuthController do
  # alias the context module
  alias Discuss.Auth
  # Invoke all controller specific functionalities via code injection (Macros)
  use DiscussWeb, :controller

  plug Ueberauth when action in [:request, :callback]

  def request(conn, _params), do: conn

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> configure_session(renew: true)
    |> put_flash(:info, "Logged out successfully")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"idp" => provider} = _params) do
    user_params = %{
      token: auth.credentials.token,
      email: auth.info.email || "",
      username:
        auth.info.nickname ||
          "#{String.split(auth.info.email, "@") |> hd}#{System.system_time(:millisecond)}",
      provider: provider
    }

    signin(conn, user_params)
  end

  defp signin(conn, user_params) do
    # Calls function from context module and handle possible output
    case Auth.signin(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome!")
        |> put_session(:user_id, user.id)
        |> redirect(to: ~p"/")

      {:error, reason} ->
        IO.inspect(reason, label: "REASON FOR ERROR: #{reason}")
        conn |> put_flash(:error, "Error during nö-.") |> redirect(to: ~p"/")
    end
  end
end
