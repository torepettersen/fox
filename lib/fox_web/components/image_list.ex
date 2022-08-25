defmodule FoxWeb.ImageList do
  use FoxWeb, :component

  def image_list(assigns) do
    ~H"""
    <ul
      role="list"
      class="grid grid-cols-2 gap-x-4 gap-y-8 sm:grid-cols-3 sm:gap-x-6 lg:grid-cols-4 xl:gap-x-8"
    >
      <%= for item <- @items do %>
        <li class="relative">
          <div
            class={[
              "group block w-full aspect-w-10 aspect-h-10 rounded-lg bg-gray-100 ring-1 ring-gray-300 focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-offset-gray-100 focus-within:ring-indigo-500 overflow-hidden",
              assigns[:on_click] && "cursor-pointer"
            ]}
            phx-click={assigns[:on_click]}
            phx-value-key={item[@key]}
          >
            <img 
              class="object-cover pointer-events-none group-hover:opacity-75"
              src={item[@image_url]}
            />
          </div>
          <p class="mt-2 block text-sm font-medium text-gray-900 truncate pointer-events-none">
            <%= item[@title] %>
          </p>
        </li>
      <% end %>
    </ul>
    """
  end
end
