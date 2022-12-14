defmodule FoxWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.
  This can be used in your application as:
      use FoxWeb, :controller
      use FoxWeb, :view
  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.
  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  @live_views FoxWeb.Router
              |> Phoenix.Router.routes()
              |> Enum.filter(&(&1.helper == "live"))
              |> Enum.map(& &1.metadata.log_module)

  def controller do
    quote do
      use Phoenix.Controller, namespace: FoxWeb

      import Plug.Conn
      import FoxWeb.Gettext
      import Phoenix.LiveView.Controller
      alias FoxWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/fox_web/modules",
        namespace: FoxWeb

      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {FoxWeb.LayoutView, "app.html"}

      unquote(view_helpers())
      on_mount FoxWeb.InitAssigns
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import FoxWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, <.link>, <.form>, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import FoxWeb.ErrorHelpers
      import FoxWeb.Gettext
      alias FoxWeb.Router.Helpers, as: Routes
      import FoxWeb.Components
      import FoxWeb.ViewHelpers

      unquote(live_aliases())
    end
  end

  defp live_aliases do
    for module <- @live_views do
      quote do
        alias unquote(module)
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def live_views, do: @live_views
end
