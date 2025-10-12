defmodule Discuss.Util.KeysetCursor do
  def encode_cursor({ts, id}) do
    "#{DateTime.to_unix(ts, :microsecond)}:#{id}"
    |> Base.url_encode64(padding: false)
  end

  def decode_cursor(nil), do: nil

  def decode_cursor(cursor) do
    with {:ok, bin} <- Base.url_decode64(cursor, padding: false),
         [ts_str, id_str] <- String.split(bin, ":", parts: 2),
         {ts_int, ""} <- Integer.parse(ts_str),
         {id, ""} <- Integer.parse(id_str),
         {:ok, ts} <- DateTime.from_unix(ts_int, :microsecond) do
      {ts, id}
    else
      _ -> nil
    end
  end

  def trim(items_full, page_size) do
    if length(items_full) > page_size do
      {Enum.take(items_full, page_size), true}
    else
      {items_full, false}
    end
  end

  def extract_struct_value(nil), do: nil

  def extract_struct_value(%{inserted_at: ts, id: id}), do: {ts, id}
end
