defmodule Discuss.Forum do
  @moduledoc """
  The Forum context.
  """

  import Ecto.Query, warn: false
  import Discuss.Util.KeysetCursor
  alias Discuss.Repo

  alias Discuss.Forum.Topic
  alias Discuss.Forum.Comment
  alias Discuss.Account.User

  @default_page_size 10

  @doc """
  Returns the list of topics.

  ## Examples

      iex> list_topics()
      [%Topic{}, ...]

  """
  def list_topics(opts \\ []) do
    page_size = opts[:page_size] || @default_page_size
    limit = page_size + 1
    after_cursor = decode_cursor(opts[:after])
    before_cursor = decode_cursor(opts[:before])

    # => {ts, id} | nil
    decoded = decode_cursor(opts[:after])

    base_query =
      from t in Topic,
        order_by: [desc: t.inserted_at, desc: t.id]

    cond do
      after_cursor ->
        {ts, id} = after_cursor

        query =
          from t in base_query,
            where: t.inserted_at < ^ts or (t.inserted_at == ^ts and t.id < ^id),
            limit: ^limit

        items_full = Repo.all(query)
        {items, has_more} = trim(items_full, page_size)

        %{
          items: items,
          next_cursor:
            if(has_more, do: encode_cursor(extract_struct_value(List.last(items))), else: nil),
          # we came from somewhere, allow going back
          prev_cursor: encode_cursor(extract_struct_value(List.first(items))),
          page_size: page_size
        }

      before_cursor ->
        {ts, id} = before_cursor

        query =
          from t in Topic,
            where:
              t.inserted_at > ^ts or
                (t.inserted_at == ^ts and t.id > ^id),
            order_by: [asc: t.inserted_at, asc: t.id],
            limit: ^limit

        items_full = Repo.all(query)
        {asc_slice, has_more_newer} = trim(items_full, page_size)
        items = Enum.reverse(asc_slice)

        %{
          items: items,
          # older
          next_cursor: encode_cursor(extract_struct_value(List.last(items))),
          prev_cursor:
            if(has_more_newer,
              do: encode_cursor(extract_struct_value(List.first(items))),
              else: nil
            ),
          page_size: page_size
        }

      true ->
        query =
          from t in base_query,
            limit: ^limit

        items_full = Repo.all(query)
        {items, has_more} = trim(items_full, page_size)

        %{
          items: items,
          next_cursor:
            if(has_more, do: encode_cursor(extract_struct_value(List.last(items))), else: nil),
          prev_cursor: nil,
          page_size: page_size
        }
    end
  end

  def list_topic_comments(opts \\ []) do
    page_size = opts[:page_size] || @default_page_size
    topic_id = opts[:topic_id]
    limit = page_size + 1
    after_cursor = decode_cursor(opts[:after])
    before_cursor = decode_cursor(opts[:before])

    # => {ts, id} | nil
    decoded = decode_cursor(opts[:after])

    base_query =
      from c in Comment,
        join: u in User,
        on: c.user_id == u.id,
        preload: [user: u],
        order_by: [desc: c.inserted_at, desc: c.id]

    cond do
      after_cursor ->
        {ts, id} = after_cursor

        query =
          from c in base_query,
            where:
              (c.inserted_at < ^ts or (c.inserted_at == ^ts and c.id < ^id)) and
                c.topic_id == ^topic_id,
            limit: ^limit

        items_full = Repo.all(query)
        {items, has_more} = trim(items_full, page_size)

        %{
          items: items,
          next_cursor:
            if(has_more, do: encode_cursor(extract_struct_value(List.last(items))), else: nil),
          # we came from somewhere, allow going back
          prev_cursor: encode_cursor(extract_struct_value(List.first(items))),
          page_size: page_size
        }

      before_cursor ->
        {ts, id} = before_cursor

        query =
          from c in base_query,
            where:
              (c.inserted_at > ^ts or
                 (c.inserted_at == ^ts and c.id > ^id)) and
                c.topic_id == ^topic_id,
            order_by: [asc: c.inserted_at, asc: c.id],
            limit: ^limit

        items_full = Repo.all(query)
        {asc_slice, has_more_newer} = trim(items_full, page_size)
        items = Enum.reverse(asc_slice)

        %{
          items: items,
          # older
          next_cursor: encode_cursor(extract_struct_value(List.last(items))),
          prev_cursor:
            if(has_more_newer,
              do: encode_cursor(extract_struct_value(List.first(items))),
              else: nil
            ),
          page_size: page_size
        }

      true ->
        query =
          from c in base_query,
            where: c.topic_id == ^topic_id,
            limit: ^limit

        items_full = Repo.all(query)
        {items, has_more} = trim(items_full, page_size)

        %{
          items: items,
          next_cursor:
            if(has_more, do: encode_cursor(extract_struct_value(List.last(items))), else: nil),
          prev_cursor: nil,
          page_size: page_size
        }
    end
  end

  @doc """
  Gets a single topic.

  Raises `Ecto.NoResultsError` if the Topic does not exist.

  ## Examples

      iex> get_topic!(123)
      %Topic{}

      iex> get_topic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_topic!(id), do: Repo.get!(Topic, id)

  @doc """
  Creates a topic.

  ## Examples

      iex> create_topic(%{field: value})
      {:ok, %Topic{}}

      iex> create_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_topic(attrs \\ %{}, user) do
    user
    |> Ecto.build_assoc(:topics, attrs)
    |> Repo.insert()
  end

  # same solution with put_assoc
  # def create_topic(attrs \\ %{}, user_info) do
  #   user = user_info |> Repo.preload(:topics)
  #   attrs_changeset = Topic.changeset(%Topic{}, attrs)
  #   user_changeset =
  #     user |> Ecto.Changeset.change() |> Ecto.Changeset.put_assoc(:topics, [attrs_changeset | user.topics])

  #   Repo.update(user_changeset)
  # end

  @doc """
  Updates a topic.

  ## Examples

      iex> update_topic(topic, %{field: new_value})
      {:ok, %Topic{}}

      iex> update_topic(topic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a topic.

  ## Examples

      iex> delete_topic(topic)
      {:ok, %Topic{}}

      iex> delete_topic(topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking topic changes.

  ## Examples

      iex> change_topic(topic)
      %Ecto.Changeset{data: %Topic{}}

  """
  def change_topic(%Topic{} = topic, attrs \\ %{}) do
    Topic.changeset(topic, attrs)
  end

  alias Discuss.Forum.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}, user) do
    user
    |> Ecto.build_assoc(:comments, attrs)
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
