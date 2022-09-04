defmodule Fox.Accounts.Transaction do
  use Fox.Schema

  alias Fox.Accounts.Account
  alias Fox.Users.User

  @transaction_statues [:booked, :pending]

  schema "transactions" do
    field :status, Ecto.Enum, values: @transaction_statues
    field :transaction_id, :string
    field :booking_date, :date
    field :transaction_date, :date
    field :amount, Money.Ecto.Composite.Type
    field :type, :string
    field :party, :string
    field :additional_information, :string

    belongs_to :account, Account
    belongs_to :user, User

    timestamps()
  end
end
