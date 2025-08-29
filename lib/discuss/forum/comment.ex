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
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end
