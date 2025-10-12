defmodule DiscussWeb.ModalComponent do
  use Phoenix.Component

  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :on_confirm, :string, default: nil
  attr :on_cancel, :string, default: nil
  attr :confirm_text, :string, default: "Confirm"
  attr :cancel_text, :string, default: "Cancel"
  attr :confirm_class, :string, default: "bg-blue-500 hover:bg-blue-600"
  attr :cancel_class, :string, default: "bg-gray-300 hover:bg-gray-400"
  slot :inner_block, required: true

  def custom_modal(assigns) do
    ~H"""
    <div id={@id} class="fixed inset-0 z-50 hidden">
      <!-- Dark overlay to dim the body when modal is active -->
      <div class="fixed inset-0 bg-black bg-opacity-50" onclick={close_modal(@id)}></div>

      <!-- Modal content container -->
      <div class="fixed inset-0 flex items-center justify-center">
        <!-- Modal content -->
        <div class="relative bg-white rounded-lg shadow-lg p-6 mx-4 w-full max-w-md">
          <div class="text-center">
            <h2 class="text-xl font-bold text-gray-900 mb-4"><%= @title %></h2>

            <!-- Content slot where the value of the attr passed gets rendered -->
            <div class="text-gray-600 mb-6">
              <%= render_slot(@inner_block) %>
            </div>

            <!-- Action buttons -->
            <div class="flex justify-center gap-4">
              <button
                type="button"
                onclick={close_modal(@id)}
                class={"px-6 py-2 text-gray-700 rounded-lg transition-colors #{@cancel_class}"}
              >
                <%= @cancel_text %>
              </button>
              <%= if @on_confirm do %>
                <button
                  type="button"
                  onclick={@on_confirm}
                  class={"px-6 py-2 text-white rounded-lg transition-colors #{@confirm_class}"}
                >
                  <%= @confirm_text %>
                </button>
              <% end %>
            </div>
          </div>

          <!-- Close button -->
          <button
            type="button"
            onclick={close_modal(@id)}
            class="absolute top-4 right-4 text-gray-400 hover:text-gray-600"
            aria-label="Close"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
      </div>
    </div>
    """
  end

  # Helper function for the onclick
  defp close_modal(id), do: "closeModal('#{id}')"
end
