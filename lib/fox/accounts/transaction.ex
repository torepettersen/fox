defmodule Fox.Accounts.Transaction do
  use Fox.Schema

  import Ecto.Changeset
  alias Fox.Accounts.Account
  alias Fox.Users.User

  @transaction_statuses [:booked, :pending]

  schema "transactions" do
    field :status, Ecto.Enum, values: @transaction_statuses
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

  @required_fileds [
    :status,
    :transaction_id,
    :booking_date,
    :transaction_date,
    :amount,
    :user_id
  ]
  @fields [:type, :party, :additional_information, :account_id | @required_fileds]

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @fields)
    |> validate_required(@required_fileds)
  end
end
