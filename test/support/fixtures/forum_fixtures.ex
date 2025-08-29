defmodule Discuss.ForumFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Discuss.Forum` context.
  """

  @doc """
  Generate a topic.
  """
  def topic_fixture(attrs \\ %{}) do
    {:ok, topic} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> Discuss.Forum.create_topic()

    topic
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        content: "some content"
      })
      |> Discuss.Forum.create_comment()

    comment
  end
end
