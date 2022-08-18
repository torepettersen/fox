defmodule FoxWeb.UserResetPasswordLive do
  use FoxWeb, :live_view

  alias Phoenix.View
  alias Fox.Users
  alias FoxWeb.UserResetPasswordView
  alias FoxWeb.UserSessionLive

  def mount(params, _session, socket) do
    socket = maybe_setup_edit_form(socket, params)
    {:ok, socket}
  end

  def render(%{live_action: :new} = assigns) do
    View.render(UserResetPasswordView, "new.html", assigns)
  end

  def render(%{live_action: :edit} = assigns) do
    View.render(UserResetPasswordView, "edit.html", assigns)
  end

  def handle_event("create_reset_token", %{"user" => %{"email" => email}}, socket) do
    if user = Users.get_user_by_email(email) do
      Users.deliver_user_reset_password_instructions(
        user,
        &Routes.user_reset_password_url(socket, :edit, &1)
      )
    end

    socket =
      socket
      |> put_flash(
        :info,
        "If your email is in our system, you will receive instructions to reset your password shortly."
      )
      |> push_redirect(to: "/")

    {:noreply, socket}
  end

  def handle_event("reset_password", %{"user" => params}, %{assigns: %{user: user}} = socket) do
    socket =
      case Users.reset_user_password(user, params) do
        {:ok, _} ->
          socket
          |> put_flash(:info, "Password reset successfully.")
          |> push_redirect(to: Routes.live_path(socket, UserSessionLive))

        {:error, changeset} ->
          assign(socket, changeset: changeset)
      end

    {:noreply, socket}
  end

  defp maybe_setup_edit_form(socket, %{"token" => token} = _params) do
    if user = Users.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token, changeset: Users.change_user_password(user))
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> push_redirect(to: "/")
    end
  end

  defp maybe_setup_edit_form(socket, _session), do: socket
end
