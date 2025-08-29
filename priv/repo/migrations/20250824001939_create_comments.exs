defmodule Discuss.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text
      add :user_id, references(:users)
      add :topic_id, references(:topics)

      timestamps(type: :utc_datetime)
    end
  end
end
