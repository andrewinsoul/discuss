defmodule DiscussWeb.CommentChannel do
  use DiscussWeb, :channel

  alias Discuss.Forum
  alias Discuss.Forum.Topic
  alias Discuss.Forum.Comment

  @impl true
  def join("comment:" <> topic_id, payload, socket) do
    topic_id = String.to_integer(topic_id)
    topic = Forum.get_topic!(topic_id)

    %{
      items: comments,
      next_cursor: next_cursor,
      prev_cursor: prev_cursor,
      page_size: page_size
    } =
      Forum.list_topic_comments(
        after: nil,
        before: nil,
        topic_id: topic_id
      )

    if authorized?(payload) do
      {
        :ok,
        %{
          comments: comments,
          next_cursor: next_cursor,
          prev_cursor: prev_cursor
        },
        assign(socket, :topic, topic)
      }
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("comment:add", %{"content" => content}, socket) do
    topic = socket.assigns.topic
    user = socket.assigns.user_id
    payload = %{"content" => content} |> Map.put_new("topic_id", topic.id)

    case Forum.create_comment(payload, user) do
      {:ok, comment} ->
        broadcast!(socket, "comment:#{topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (comment:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
