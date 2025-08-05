defmodule DiscussWeb.Plugs.CheckTopicOwner do
  alias Discuss.Topics.Topic
  alias Discuss.Repo
  import Plug.Conn
  import Phoenix.Controller

  use Phoenix.VerifiedRoutes,
    endpoint: DiscussWeb.Endpoint,
    router: DiscussWeb.Router,
    statics: DiscussWeb.static_paths()

  def init(_params) do
  end

  defp is_integer_string?(str) do
    case Integer.parse(str) do
      {_, ""} -> true
      _ -> false
    end
  end

  def call(%Plug.Conn{params: params} = conn, _opts) do
    %{"id" => topic_id} = params

    if is_integer_string?(topic_id) do
      topic_info = Repo.get(Topic, topic_id)

      case topic_info do
        nil ->
          conn
          |> put_flash(:error, "Topic not found!")
          |> redirect(to: ~p"/")
          |> halt()

        _ ->
          if conn.assigns.user.id == topic_info.user_id do
            conn
          else
            conn
            |> put_flash(:error, "You are not permitted to perform that operation")
            |> redirect(to: ~p"/")
            |> halt()
          end
      end
    else
      conn
      |> put_flash(:error, "Invalid parameter passed")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
