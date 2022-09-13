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
    data = graph_data(account, date_range)

    %{
      labels: date_range |> Enum.to_list(),
      data: data,
      max: graph_max(data)
    }
  end

  defp graph_data(account, date_range) do
    account.interim_available_amount
    |> Accounts.balance_development(account.transactions, date_range)
    |> Enum.map(fn
      %{amount: amount} -> amount |> Decimal.round() |> Decimal.to_integer()
      nil -> nil
    end)
  end

  defp graph_max(data) do
    data
    |> Enum.reject(&is_nil/1)
    |> Enum.max()
    |> Kernel.*(1.1)
  end

  defp date_range do
    today = Date.utc_today()
    end_of_last_month = DateHelper.end_of_last_month(today)
    end_of_month = Date.end_of_month(today)
    Date.range(end_of_last_month, end_of_month)
  end
end
