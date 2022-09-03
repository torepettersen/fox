defmodule Fox.Factory do
  use ExMachina.Ecto, repo: Fox.Repo

  alias Fox.Accounts.Account
  alias Fox.Accounts.AccountGroup
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

  def account_group_factory do
    %AccountGroup{
      name: "Savings",
      user: build(:user)
    }
  end

  def account_factory do
    %Account{
      name: "Brukskonto",
      interim_available_amount: Money.new(:NOK, 123),
      expected_amount: Money.new(:NOK, 123),
      iban: "NO0000000000000",
      bban: "0000000000000",
      bic: "DNBANOKKXXX",
      owner_name: "Tore Pettersen",
      visible: true,
      nordigen_id: Ecto.UUID.generate(),
      requisition: build(:requisition),
      account_group: build(:account_group),
      user: build(:user)
    }
  end
end
