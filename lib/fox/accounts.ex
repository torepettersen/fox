defmodule Fox.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Fox.Accounts.Account
  alias Fox.Repo

  def list_accounts(args \\ %{}) do
    from(account in Account)
    |> Account.query(args)
    |> Repo.all()
  end

  def fetch_account(id) do
    Repo.get(Account, id)
    |> Repo.wrap_result()
  end
end
