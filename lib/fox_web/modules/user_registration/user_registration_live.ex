defmodule FoxWeb.UserRegistrationLive do
  use FoxWeb, :live_view

  alias Fox.Users
  alias Fox.Users.User
  alias FoxWeb.UserSessionLive

  def mount(_params, session, socket) do
    socket = assign_changeset(socket, session)
    {:ok, socket}
  end

  defp assign_changeset(socket, %{"changeset" => changeset} = _session) do
    assign(socket, changeset: changeset)
  end

  defp assign_changeset(socket, _session) do
    assign(socket, changeset: Users.change_user_registration(%User{}))
  end
end
