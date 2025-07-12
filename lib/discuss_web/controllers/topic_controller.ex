defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias Discuss.Repo
  alias Discuss.Topics.Topic
  import Phoenix.Component, only: [to_form: 1]

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render(conn, :index, topics: topics)
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{})

    render(conn, :new, form: to_form(changeset))
  end

  def create_topic(conn, %{"topic" => title}) do
    changeset = Topic.changeset(%Topic{}, title)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        put_flash(conn, :info, "Topic Successfully Created")
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        render(conn, :new, form: to_form(changeset))
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)

    render(conn, :edit, form: to_form(changeset), topic: topic)
  end

  def edit_topic(conn, %{"topic" => title, "id" => topic_id}) do
    old_topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(old_topic, title)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        put_flash(conn, :info, "Topic Successfully Updated")
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        render(conn, :edit, form: to_form(changeset), topic: old_topic)
    end
  end
end
