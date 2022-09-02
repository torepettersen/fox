defmodule Fox.Accounts.AccountGroup do
  use Fox.Schema

  import Ecto.Changeset
  alias Fox.Users.User
  alias Fox.Accounts.Account

  schema "account_groups" do
    field :name, :string
    belongs_to :user, User
    has_many :accounts, Account

    timestamps()
  end

  @doc false
  def changeset(account_group, attrs) do
    account_group
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
