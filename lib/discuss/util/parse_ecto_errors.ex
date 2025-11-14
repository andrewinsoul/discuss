defmodule Discuss.Util.ParseEctoErrors do
  def parse(changeset_error) do
    IO.inspect(changeset_error, label: "Util_Error >>>>> ")
    Ecto.Changeset.traverse_errors(changeset_error, fn {msg, opts} ->
      IO.inspect(msg, label: "Nature >>>>>> ")
      IO.inspect(opts, label: "Nuture >>>>>> ")
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)

  end
end
