defmodule FoxWeb.AccountsLive do
  use FoxWeb, :live_view

  alias Fox.Accounts
  alias Fox.Accounts.Account
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
    |> Enum.map(& &1.interim_available_amount)
    |> Enum.reduce(fn amount, result ->
      case Money.add(result, amount) do
        {:ok, new_result} -> new_result
        _ -> result
      end
    end)
  end

  def format_account_number(%Account{iban: iban}), do: format_account_number(iban)

  def format_account_number("NO" <> _ = iban) do
    Regex.replace(~r/^(.{4})(\d{4})(\d{2})(\d{5})$/, iban, "\\2.\\3.\\4")
  end

  def format_account_number(iban), do: iban

  @default_opts [fractional_digits: 0, rounding_mode: :down]
  def format_amount(money, opts \\ [])

  def format_amount(%Account{interim_available_amount: amount}, opts) do
    format_amount(amount, opts)
  end

  def format_amount(%Money{} = money, opts) do
    opts = Keyword.merge(@default_opts, opts)

    case opts[:show_currency] do
      false -> format_amount(money.amount, opts)
      _ -> format_money(money, opts)
    end
  end

  def format_amount(amount, opts) do
    case Fox.Cldr.Number.to_string(amount, opts) do
      {:ok, amount} -> amount
      _ -> ""
    end
  end

  defp format_money(%Money{} = money, opts) do
    case Money.to_string(money, opts) do
      {:ok, amount} -> amount
      _ -> ""
    end
  end
end
