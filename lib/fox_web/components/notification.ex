defmodule FoxWeb.NotificationComponent do
  use FoxWeb, :component

  attr :flash, :list

  def notifications(assigns) do
    ~H"""
    <div class="fixed inset-0 flex items-end px-4 py-24 pointer-events-none sm:px-6 sm:items-start" aria-live="assertive">
      <div class="w-full flex flex-col items-center space-y-4 sm:items-end">
        <%= for {type, message} <- @flash do %>
          <.notification type={type} message={message} />
        <% end %>
      </div>
    </div>
    """
  end

  defp notification(assigns) do
    ~H"""
    <div class="max-w-sm w-full bg-white shadow-lg rounded-lg pointer-events-auto ring-1 ring-black ring-opacity-5 overflow-hidden">
      <div class="p-4">
        <div class="flex items-start">
          <div class="flex-shrink-0">
            <.icon type={@type} />
          </div>
          <div class="ml-3 w-0 flex-1 pt-0.5">
            <p class="text-sm font-medium text-gray-900"><%= @message %></p>
          </div>
          <div class="ml-4 flex-shrink-0 flex">
            <.button_close type={@type} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp icon(%{type: "info"} = assigns) do
    ~H"""
    <Heroicons.information_circle class="h-6 w-6 text-blue-600" />
    """
  end

  defp icon(%{type: "success"} = assigns) do
    ~H"""
    <Heroicons.check_circle class="h-6 w-6 text-green-600" />
    """
  end

  defp icon(%{type: "error"} = assigns) do
    ~H"""
    <Heroicons.exclamation_circle class="h-6 w-6 text-red-600" />
    """
  end

  defp button_close(assigns) do
    ~H"""
    <button 
      phx-click="lv:clear-flash"
      phx-value-key={@type}
      type="button"
      class="rounded-md inline-flex text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
    >
      <span class="sr-only">Close</span>
      <Heroicons.x_mark solid class="h-5 w-5" />
    </button>
    """
  end
end
