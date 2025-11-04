defmodule Discuss.Account.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:username, :email]}

  schema "users" do
    field :token, :string
    field :username, :string
    field :provider, :string
    field :email, :string

    has_many :topics, Discuss.Forum.Topic
    has_many :comments, Discuss.Forum.Comment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :provider, :token])
    |> validate_required([:username, :provider, :token])
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end
end
