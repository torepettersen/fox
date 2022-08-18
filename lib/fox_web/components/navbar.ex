defmodule FoxWeb.NavbarComponent do
  use FoxWeb, :component

  alias FoxWeb.Endpoint
  alias FoxWeb.UserSessionLive
  alias FoxWeb.UserRegistrationLive

  def navbar(assigns) do
    ~H"""
    <header class="py-10">
      <.container>
        <nav class="relative z-50 flex justify-between">
          <div class="flex items-center md:gap-x-12">
            <.link navigate="/" class="text-xl text-bold">
              Rio<span class="text-blue-600">Generator</span>
            </.link>
            <div class="hidden md:flex md:gap-x-6">
              <.nav_link href="https://hexdocs.pm/phoenix/overview.html">Phoenix</.nav_link>
              <.nav_link href="https://tailwindcss.com/">Tailwind CSS</.nav_link>
              <.nav_link href="https://tailwindui.com/">Tailwind UI</.nav_link>
              <%= if function_exported?(Routes, :live_dashboard_path, 2) do %>
                <.nav_link href={Routes.live_dashboard_path(Endpoint, :home)}>Live dashboard</.nav_link>
              <% end %>
            </div>
          </div>
          <div class="flex items-center gap-x-5 md:gap-x-8">
            <%= if @current_user do %>
              <.nav_link href={Routes.user_session_path(Endpoint, :delete)} method="delete">
                Sign out
              </.nav_link>
            <% else %>
              <div class="hidden md:block">
                <.nav_link navigate={Routes.live_path(Endpoint, UserSessionLive)}>Sign in</.nav_link>
              </div>
              <.button navigate={Routes.live_path(Endpoint, UserRegistrationLive)}>Register</.button>
            <% end %>
          </div>
        </nav>
      </.container>
    </header>
    """
  end

  defp nav_link(assigns) do
    rest = Map.delete(assigns, :class)

    ~H"""
    <.link class="inline-block rounded-lg py-1 px-2 text-sm text-slate-700 hover:bg-slate-100 hover:text-slate-900" {rest}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
