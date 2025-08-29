defmodule Discuss.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :user_id, references(:users)

      timestamps(type: :utc_datetime)
    end
  end
end
