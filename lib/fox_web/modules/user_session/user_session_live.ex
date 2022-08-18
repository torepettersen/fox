defmodule FoxWeb.UserSessionLive do
  use FoxWeb, :live_view

  alias FoxWeb.UserRegistrationLive

  def mount(_params, session, socket) do
    socket = assign(socket, error_message: session["error_message"])
    {:ok, socket}
  end
end
