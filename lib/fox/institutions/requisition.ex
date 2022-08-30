defmodule Fox.Institutions.Requisition do
  use Fox.Schema
  import Ecto.Changeset
  alias Fox.Users.User

  schema "requisitions" do
    field :institution_id, :string
    field :status, :string
    field :link, :string
    field :nordigen_id, :string
    field :last_updated, :utc_datetime_usec
    belongs_to :user, User

    timestamps()
  end

  @required_fields [:status, :nordigen_id, :link, :institution_id, :user_id]
  @fields [:id, :last_updated | @required_fields]

  @doc false
  def changeset(requisition, attrs) do
    requisition
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:user_id, :institution_id])
  end
end
