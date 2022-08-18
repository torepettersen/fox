defmodule Fox.Factory do
  use ExMachina.Ecto, repo: Fox.Repo

  alias Fox.Users.User

  def valid_user_password, do: "hello world!"

  def user_factory do
    %User{
      email: sequence(:email, &"user#{&1}@example.com"),
      hashed_password: Argon2.hash_pwd_salt(valid_user_password())
    }
  end
end
