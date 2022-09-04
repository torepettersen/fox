defmodule Fox.Accounts.Account do
  use Fox.Schema

  import Ecto.Changeset
  import Ecto.Query
  alias Fox.Accounts.AccountGroup
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
    |> validate_required(@required_fields)
  end

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
