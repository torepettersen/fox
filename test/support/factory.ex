defmodule Fox.Factory do
  use ExMachina.Ecto, repo: Fox.Repo

  alias Fox.Institutions.Requisition
  alias Fox.Users.User

  def valid_user_password, do: "hello world!"

  def user_factory do
    %User{
      email: sequence(:email, &"user#{&1}@example.com"),
      hashed_password: Argon2.hash_pwd_salt(valid_user_password())
    }
  end

  def requisition_factory do
    %Requisition{
      institution_id: sequence(:institution_id, &"Bank_#{&1}"),
      link: "some link",
      nordigen_id: "some nordigen_id",
      status: "some status",
      last_updated: DateTime.utc_now(),
      user: build(:user)
    }
  end
end
