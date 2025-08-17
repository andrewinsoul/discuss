defmodule DiscussWeb.CommentChannel do
  alias Discuss.Comments.Comment
  alias Discuss.Repo
  alias Discuss.Topics.Topic
  use DiscussWeb, :channel

  @impl true
  def join("comment:" <> topic_id, payload, socket) do
    topic_id = String.to_integer(topic_id)
    topic = Repo.get(Topic, topic_id) |> Repo.preload(:comments)

    if authorized?(payload) do
      {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("comment:add", %{"content" => content}, socket) do
    topic = socket.assigns.topic
    changeset = topic |> Ecto.build_assoc(:comments) |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        broadcast!(socket, "comment:#{topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}

      {:error, _reason} ->
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
    IO.inspect(payload)
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
