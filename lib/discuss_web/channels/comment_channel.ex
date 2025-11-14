defmodule DiscussWeb.CommentChannel do
  use DiscussWeb, :channel

  alias Discuss.Forum
  alias Discuss.Util.ParseEctoErrors

  @impl true
  def join("comment:" <> topic_id, _payload, socket) do
    topic_id = String.to_integer(topic_id)
    {:ok, assign(socket, :topic_id, topic_id)}
  end

  def handle_in("comment:add", %{"content" => content}, socket) do
    topic_id = socket.assigns.topic_id
    user = socket.assigns.user_id
    payload = %{"content" => content} |> Map.put_new("topic_id", topic_id)

    case Forum.create_comment(payload, user) do
      {:ok, comment} ->
        broadcast!(socket, "comment:#{topic_id}:new", %{comment: comment})
        {:reply, {:ok, %{message: "comment created"}}, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = ParseEctoErrors.parse(changeset)
        {:reply, {:error, %{errors: errors}}, socket}
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
end
