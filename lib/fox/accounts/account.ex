defmodule Fox.Accounts.Account do
  use Fox.Schema

  import Ecto.Changeset
  import Ecto.Query
  alias Fox.Accounts.AccountGroup
  alias Fox.Accounts.Transaction
  alias Fox.Institutions.Requisition
  alias Fox.Users.User

  schema "accounts" do
    field :name, :string
    field :interim_available_amount, Money.Ecto.Composite.Type
    field :expected_amount, Money.Ecto.Composite.Type
    field :iban, :string
    field :bban, :string
    field :bic, :string
    field :owner_name, :string
    field :visible, :boolean, default: true
    field :nordigen_id, :string

    belongs_to :requisition, Requisition
    belongs_to :account_group, AccountGroup
    belongs_to :user, User

    has_many :transactions, Transaction, preload_order: [desc: :transaction_date]

    timestamps()
  end

  @required_fields [
    :name,
    :visible,
    :nordigen_id,
    :user_id
  ]
  @fields [
    :interim_available_amount,
    :expected_amount,
    :iban,
    :bban,
    :bic,
    :owner_name,
    :account_group_id,
    :requisition_id
    | @required_fields
  ]

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, @fields)
    |> cast_transactions()
    |> validate_required(@required_fields)
  end

  defp cast_transactions(%{params: %{"transactions" => transactions}} = changeset) do
    {_, user_id} = fetch_field(changeset, :user_id)
    new_transactions = Enum.map(transactions, &Map.put_new(&1, :user_id, user_id))

    changeset
    |> put_in([Access.key(:params), "transactions"], new_transactions)
    |> cast_assoc(:transactions)
  end

  defp cast_transactions(changeset), do: changeset

  def query(queryable, args) do
    Enum.reduce(args, queryable, &filter/2)
  end

  defp filter({:visible, value}, query), do: where(query, [account], account.visible == ^value)

  defp filter({:account_group, nil}, query),
    do: where(query, [account], is_nil(account.account_group_id))

  defp filter({:account_group, value}, query),
    do: where(query, [account], account.account_group_id == ^value)

  defp filter(_, query), do: query
end
