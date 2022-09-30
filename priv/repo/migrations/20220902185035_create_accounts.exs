defmodule Fox.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :name, :string
      add :interim_available_amount, :money_with_currency
      add :expected_amount, :money_with_currency
      add :closing_booked_amount, :money_with_currency
      add :opening_booked_amount, :money_with_currency
      add :iban, :string
      add :bban, :string
      add :bic, :string
      add :owner_name, :string
      add :visible, :boolean, default: true, null: false
      add :nordigen_id, :string

      add :user_id, references(:users, on_delete: :restrict), null: false
      add :requisition_id, references(:requisitions, on_delete: :restrict), null: false
      add :account_group_id, references(:account_groups, on_delete: :restrict)

      timestamps()
    end

    create index(:accounts, [:user_id])
    create index(:accounts, [:requisition_id])
    create index(:accounts, [:account_group_id])
    create unique_index(:accounts, [:nordigen_id])
  end
end
