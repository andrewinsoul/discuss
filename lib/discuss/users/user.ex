defmodule Discuss.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :email, :string
    field :provider, :string
    field :token, :string

    has_many :topics, Discuss.Topics.Topic
    has_many :comments, Discuss.Comments.Comment

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :email, :provider, :token])
    |> validate_required([:email, :provider, :token])
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end
end
