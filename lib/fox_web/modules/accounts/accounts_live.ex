defmodule FoxWeb.AccountsLive do
  use FoxWeb, :live_view

  alias Fox.Accounts
  alias Fox.Repo

  def mount(_params, _session, socket) do
    accounts = Accounts.list_accounts(visible: true)
    account_groups = group_accounts(accounts)
    total_amount = total_amount(accounts)

    socket = assign(socket, account_groups: account_groups, total_amount: total_amount)

    {:ok, socket}
  end

  defp group_accounts(accounts) do
    accounts
    |> Repo.preload(:account_group)
    |> Enum.group_by(fn account ->
      case get_in(account, [Access.key(:account_group), Access.key(:name)]) do
        nil -> "Other accounts"
        account_group -> account_group
      end
    end)
  end

  defp total_amount(accounts) do
    accounts
    |> Enum.map(&Accounts.amount/1)
    |> Enum.reduce(fn amount, result ->
      case Money.add(result, amount) do
        {:ok, new_result} -> new_result
        _ -> result
      end
    end)
  end
end
