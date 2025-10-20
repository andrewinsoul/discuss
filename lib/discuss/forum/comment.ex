defmodule Discuss.Forum.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string

    belongs_to :user, Discuss.Account.User
    belongs_to :topic, Discuss.Forum.Topic

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :user_id, :topic_id])
    |> validate_required([:content, :user_id, :topic_id])
    |> validate_length(:content, min: 1, message: "Content field cannot be empty")
  end
end
