defmodule Discuss.Auth do
  # alias Repo module
  alias Discuss.Repo
  # alias User schema
  alias Discuss.Account.User
  # imports all functions from Ecto.Query module
  import Ecto.Query

  def signin(user_params) do
    # calls a private function in the context
    create_or_update(user_params)
  end

  defp create_or_update(user_params) do
    email = user_params.email
    username = user_params.username

    # Syntax for querying a table where the value of either username column or
    # email column is the value passed. Possible because we
    # imported all Ecto Qiery's functions
    result =
      from(u in User, where: u.username == ^username or u.email == ^email)
      # Ecto query is piped to Repo to fetch the query from DB
      |> Repo.one()

    IO.inspect(user_params, label: "user payload")
    changeset = User.changeset(%User{}, user_params)

    case result do
      nil ->
        Repo.insert(changeset)

      user ->
        {:ok, user}
    end
  end
end
