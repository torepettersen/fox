defmodule FoxWeb.UserRegistrationController do
  use FoxWeb, :controller

  alias Fox.Users
  alias FoxWeb.UserAuth
  alias FoxWeb.UserRegistrationLive

  def create(conn, %{"user" => user_params}) do
    case Users.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        live_render(conn, UserRegistrationLive,
          session: %{"changeset" => changeset}
        )
    end
  end
end
