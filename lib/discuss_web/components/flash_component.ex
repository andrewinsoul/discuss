defmodule DiscussWeb.FlashComponents do
  use Phoenix.Component

  @doc """
  Simple controller-friendly flash box.
  Pass `message` (string) and `kind` (:info | :error | :success | :warning).
  """
  attr :id, :string, default: nil
  attr :message, :string, required: true
  attr :kind, :atom, default: :info

  def flash(assigns) do
    assigns =
      assigns
      |> assign_new(:id, fn -> "flash-#{assigns.kind}" end)
      |> assign(:palette, palette(assigns.kind))

    ~H"""
    <div
      id={@id}
      style="position: fixed; top: 0; right: 0"
      class={[
        "pointer-events-auto relative mb-3 flex w-full max-w-md items-start gap-3 rounded-lg border p-3 shadow-lg transition-all",
        "data-[hide=true]:opacity-0 data-[hide=true]:translate-y-2",
        @palette.bg,
        @palette.border,
        @palette.text,
        "fixed top-4 right-0"
      ]}
      role={@palette.role}
      aria-live={@palette.aria}
    >
      <i data-lucide={@palette.icon} class={["mt-0.5 h-5 w-5 shrink-0", @palette.icon_color]}></i>
      <div class="flex-1 text-sm">{@message}</div>
      <button type="button" class="flash-close" data-target={@id} aria-label="Dismiss">
        <i data-lucide="x" class="h-4 w-4"></i>
      </button>
    </div>
    """
  end

  # Tailwind palettes similar to Phoenix defaults
  defp palette(:info),
    do: %{
      bg: "bg-emerald-50",
      border: "border-emerald-200",
      text: "text-emerald-900",
      icon_color: "text-emerald-600",
      icon: "info",
      role: "status",
      aria: "polite"
    }

  defp palette(:success), do: palette(:info)

  defp palette(:error),
    do: %{
      bg: "bg-rose-50",
      border: "border-rose-200",
      text: "text-rose-900",
      icon_color: "text-rose-600",
      icon: "alert-triangle",
      role: "alert",
      aria: "assertive"
    }

  defp palette(:warning),
    do: %{
      bg: "bg-amber-50",
      border: "border-amber-200",
      text: "text-amber-900",
      icon_color: "text-amber-600",
      icon: "alert-circle",
      role: "status",
      aria: "polite"
    }

  defp palette(_), do: palette(:info)
end
