defmodule DiscussWeb.CommentController do
  use DiscussWeb, :controller

  alias Discuss.Forum
  alias Discuss.Forum.Comment

  def index(conn, _params) do
    comments = Forum.list_comments()
    render(conn, :index, comments: comments)
  end

  def new(conn, _params) do
    changeset = Forum.change_comment(%Comment{})
    render(conn, :new, changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    comment = Forum.get_comment!(id)
    render(conn, :show, comment: comment)
  end

  def edit(conn, %{"id" => id}) do
    comment = Forum.get_comment!(id)
    changeset = Forum.change_comment(comment)
    render(conn, :edit, comment: comment, changeset: changeset)
  end

  def delete(conn, %{"id" => id}) do
    comment = Forum.get_comment!(id)
    {:ok, _comment} = Forum.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: ~p"/")
  end
end
