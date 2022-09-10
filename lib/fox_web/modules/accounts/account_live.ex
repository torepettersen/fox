defmodule FoxWeb.AccountLive do
  use FoxWeb, :live_view

  alias Fox.Accounts
  alias Fox.DateHelper
  alias Fox.Repo

  def mount(%{"id" => id}, _session, socket) do
    {:ok, account} = Accounts.fetch_account(id)
    account = Repo.preload(account, :transactions)
    socket = assign(socket, account: account)

    socket = push_event(socket, "data", build_chart(account))

    {:ok, socket}
  end

  defp build_chart(account) do
    date_range = date_range()

    data =
      account.interim_available_amount
      |> Accounts.balance_development(account.transactions, date_range)
      |> Enum.map(&(&1.amount |> Decimal.round() |> Decimal.to_integer()))

    max = round10000(Enum.max(data) + 10_000)

    %{
      labels: date_range |> Enum.to_list(),
      data: data,
      max: max
    }
  end

  defp date_range do
    today = Date.utc_today()
    end_of_last_month = DateHelper.end_of_last_month(today)
    end_of_month = Date.end_of_month(today)
    Date.range(end_of_last_month, end_of_month)
  end

  defp round10000(n) when rem(n, 10_000) < 6_000, do: n - rem(n, 10_000)
  defp round10000(n), do: n + (10_000 - rem(n, 10_000))
end
