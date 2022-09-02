defmodule Fox.Repo.Migrations.CreateAccountGroups do
  use Ecto.Migration

  def change do
    create table(:account_groups) do
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:account_groups, [:user_id])
    create unique_index(:account_groups, [:user_id, :name])
  end
end
