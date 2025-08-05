defmodule DiscussWeb.AuthController do
  alias Discuss.Repo
  alias Discuss.Users.User
  use DiscussWeb, :controller
  plug Ueberauth

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"idp" => provider} = _params) do
    user_params = %{
      token: auth.credentials.token,
      email: auth.info.email,
      username:
        auth.info.nickname ||
          "#{String.split(auth.info.email, "@") |> hd}#{System.system_time(:millisecond)}",
      provider: provider
    }

    changeset = User.changeset(%User{}, user_params)
    signin(conn, changeset)
  end

  defp signin(conn, changeset) do
    case create_or_update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome!")
        |> put_session(:user_id, user.id)
        |> redirect(to: ~p"/")

      {:error, _reason} ->
        conn |> put_flash(:error, "Error during authentication") |> redirect(to: ~p"/")
    end
  end

  def logout(conn, _params) do
    conn |> configure_session(drop: true) |> redirect(to: ~p"/")
  end

  defp create_or_update(changeset) do
    email = changeset.changes.email
    username = changeset.changes.username

    result =
      from(u in User, where: u.username == ^username or u.email == ^email)
      |> Repo.one()

    case result do
      nil ->
        Repo.insert(changeset)

      user ->
        {:ok, user}
    end
  end
end
