defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias Discuss.Repo
  alias Discuss.Topics.Topic
  import Phoenix.Component, only: [to_form: 1]

  plug DiscussWeb.Plugs.RequireAuth
       when action in [:new, :create_topic, :edit, :edit_topic, :delete_topic]

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

  def delete_topic(conn, %{"id" => topic_id}) do
    with %Topic{} = topic <- Repo.get(Topic, topic_id),
         {:ok, _} <- Repo.delete(topic) do
      conn
      |> put_flash(:info, "Topic deleted successfully.")
      |> redirect(to: ~p"/")
    else
      nil ->
        conn
        |> put_flash(:info, "Topic not found!")
        |> redirect(to: ~p"/")

      _ ->
        conn
        |> put_flash(:error, "Error in deleting topic!")
        |> redirect(to: ~p"/")
    end
  end
end
