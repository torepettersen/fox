defmodule Fox.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Fox.Accounts.Account
  alias Fox.Accounts.Service
  alias Fox.Repo

  defdelegate balance_development(current_amount, transactions, range),
    to: Service.BalanceDevelopment,
    as: :call

  def list_accounts(args \\ %{}) do
    from(account in Account)
    |> Account.query(args)
    |> Repo.all()
  end

  def fetch_account(id) do
    Repo.get(Account, id)
    |> Repo.wrap_result()
  end

  def amount(%Account{opening_booked_amount: amount}) when not is_nil(amount), do: amount
  def amount(%Account{closing_booked_amount: amount}) when not is_nil(amount), do: amount
  def amount(%Account{}), do: nil
end
