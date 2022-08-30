defmodule Fox.Repo.Migrations.CreateRequisitions do
  use Ecto.Migration

  def change do
    create table(:requisitions) do
      add :institution_id, :string
      add :status, :string
      add :link, :string
      add :nordigen_id, :string
      add :last_updated, :utc_datetime_usec
      add :user_id, references(:users, on_delete: :restrict), null: false

      timestamps()
    end

    create index(:requisitions, [:user_id])
    create unique_index(:requisitions, [:user_id, :institution_id])
  end
end
