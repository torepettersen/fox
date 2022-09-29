defmodule FoxWeb.AccountLive do
  use FoxWeb, :live_view

  alias Fox.Accounts
  alias Fox.DateHelper
  alias Fox.Repo

  def mount(%{"id" => id}, _session, socket) do
    {:ok, account} = Accounts.fetch_account(id)
    account = Repo.preload(account, :transactions)
    socket = assign(socket, account: account)

    date_range = default_range() |> date_range()
    socket = push_event(socket, "data", build_chart(account, date_range))

    {:ok, socket}
  end

  def handle_event("change_range", params, socket) do
    date_range = date_range(params["form"]["range"])
    socket = push_event(socket, "data", build_chart(socket.assigns.account, date_range))
    {:noreply, socket}
  end

  defp build_chart(account, date_range) do
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

  defp date_range("week") do
    today = Date.utc_today()
    one_week_ago = Timex.shift(today, weeks: -1)
    Date.range(one_week_ago, today)
  end

  defp date_range("month") do
    today = Date.utc_today()
    three_months_ago = Timex.shift(today, months: -1)
    Date.range(three_months_ago, today)
  end

  defp date_range("three_months") do
    today = Date.utc_today()
    three_months_ago = Timex.shift(today, months: -3)
    Date.range(three_months_ago, today)
  end

  defp ranges do
    ["Last week": "week", "Last month": "month", "Last three monts": "three_months"]
  end

  defp default_range, do: "month"
end
