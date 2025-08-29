defmodule Discuss.Forum.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string

    belongs_to :user, Discuss.Account.User
    has_many :comments, Discuss.Forum.Comment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
