defmodule Fox.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :status, :string
      add :transaction_id, :string
      add :booking_date, :date
      add :transaction_date, :date
      add :amount, :money_with_currency
      add :type, :string
      add :party, :string
      add :additional_information, :string

      add :account_id, references(:accounts, on_delete: :restrict), null: false
      add :user_id, references(:users, on_delete: :restrict), null: false

      timestamps()
    end

    create index(:transactions, [:user_id])
    create index(:transactions, [:account_id])
    create unique_index(:transactions, [:transaction_id])
  end
end
