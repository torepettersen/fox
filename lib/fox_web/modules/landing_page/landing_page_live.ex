defmodule FoxWeb.LandingPageLive do
  use FoxWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket, layout: {FoxWeb.LayoutView, "live.html"}}
  end

  def render(assigns) do
    ~H"""

    """
  end
end
