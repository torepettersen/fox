defmodule FoxWeb.InitAssigns do
  use Phoenix.Component

  alias Fox.Users
  alias Fox.Repo

  def on_mount(:default, _params, session, socket) do
    socket = assign_new(socket, :current_user, fn -> get_user(session) end)

    Repo.put_user(socket.assigns.current_user)

    {:cont, socket}
  end

  defp get_user(%{"user_token" => user_token} = _session) do
    Users.get_user_by_session_token(user_token)
  end

  defp get_user(_session), do: nil
end
