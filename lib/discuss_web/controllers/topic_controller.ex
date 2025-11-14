defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  alias Discuss.Forum
  alias Discuss.Forum.Topic
  alias Discuss.Forum.Comment

  def index(conn, params) do
    %{
      items: topics,
      next_cursor: next_cursor,
      prev_cursor: prev_cursor,
      page_size: _page_size
    } =
      Forum.list_topics(after: params["after"], before: params["before"])

    render(conn, :index, topics: topics, next_cursor: next_cursor, prev_cursor: prev_cursor)
  end

  def new(conn, _params) do
    changeset = Forum.change_topic(%Topic{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"topic" => topic_params}) do
    user = conn.assigns[:user]

    case Forum.create_topic(
           %{
             title: topic_params["title"]
           },
           user
         ) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: ~p"/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => topic_id} = params) do
    topic = Forum.get_topic!(topic_id)
    comment_changeset = Forum.change_comment(%Comment{})

    %{
      items: comments,
      next_cursor: next_cursor,
      prev_cursor: prev_cursor,
      page_size: page_size
    } =
      Forum.list_topic_comments(
        topic_id: topic_id,
        after: params["after"],
        before: params["before"]
      )

    conn
    |> render(
      :show,
      topic: topic,
      changeset: comment_changeset,
      comments: comments,
      next_cursor: next_cursor,
      prev_cursor: prev_cursor,
      page_size: page_size
    )
  end

  defp show_topic_comments(_conn, %{"topic_id" => id} = params) do
    Forum.list_topic_comments(
      after: params["after"],
      before: params["before"],
      topic_id: id
    )
  end

  def create_comment(conn, %{"comment" => comment_params, "topic_id" => topic_id}) do
    user = conn.assigns[:user]

    payload =
      comment_params
      |> Map.put_new("topic_id", topic_id)
      |> Map.put("inserted_at", NaiveDateTime.local_now() |> DateTime.from_naive!("Etc/UTC"))

    case Forum.create_comment(payload, user) do
      {:ok, _comment} ->
        conn
        |> redirect(to: ~p"/topics/#{topic_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        topic = Forum.get_topic!(topic_id)
        result = show_topic_comments(conn, %{"topic_id" => topic_id})

        render(conn, :show,
          changeset: changeset,
          comments: result.items,
          topic: topic,
          next_cursor: result.next_cursor,
          prev_cursor: result.prev_cursor
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    topic = Forum.get_topic!(id)
    changeset = Forum.change_topic(topic)
    render(conn, :edit, topic: topic, changeset: changeset)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Forum.get_topic!(id)

    case Forum.update_topic(topic, topic_params) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: ~p"/")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, topic: topic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Forum.get_topic!(id)
    {:ok, _topic} = Forum.delete_topic(topic)

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: ~p"/")
  end
end
