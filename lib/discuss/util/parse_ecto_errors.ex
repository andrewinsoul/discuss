defmodule Discuss.Util.ParseEctoErrors do
  def parse(changeset_error) do
    Ecto.Changeset.traverse_errors(changeset_error, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)

  end
end
