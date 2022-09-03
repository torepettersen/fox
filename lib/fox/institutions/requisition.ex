defmodule Fox.Institutions.Requisition do
  use Fox.Schema
  import Ecto.Changeset
  alias Fox.Accounts.Account
  alias Fox.Users.User

  schema "requisitions" do
    field :institution_id, :string
    field :status, :string
    field :link, :string
    field :nordigen_id, :string
    field :last_updated, :utc_datetime_usec
    belongs_to :user, User
    has_many :accounts, Account, on_replace: :delete_if_exists

    timestamps()
  end

  @required_fields [:status, :nordigen_id, :link, :institution_id, :user_id]
  @fields [:id, :last_updated | @required_fields]

  @doc false
  def changeset(requisition, attrs) do
    requisition
    |> cast(attrs, @fields)
    |> cast_accounts()
    |> validate_required(@required_fields)
    |> unique_constraint([:user_id, :institution_id])
  end

  defp cast_accounts(%{params: %{"accounts" => accounts}} = changeset) do
    {_, user_id} = fetch_field(changeset, :user_id)
    new_accouts = Enum.map(accounts, &Map.put_new(&1, :user_id, user_id))

    changeset
    |> put_in([Access.key(:params), "accounts"], new_accouts)
    |> cast_assoc(:accounts)
  end

  defp cast_accounts(changeset), do: changeset
end
