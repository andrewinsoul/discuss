defmodule DiscussWeb.CommentChannel do
  alias Discuss.Repo
  alias Discuss.Topics.Topic
  use DiscussWeb, :channel

  @impl true
  def join("comment:" <> topic_id, payload, socket) do
    IO.puts("+++++++++++ #{topic_id}")
    topic_id = String.to_integer(topic_id)
    topic = Repo.get(Topic, topic_id)

    if authorized?(payload) do
      {:ok, %{"id" => topic.id, "title" => topic.title}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("comment:add", payload, socket) do
    IO.inspect(payload)
    {:reply, {:ok, payload}, socket}
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
