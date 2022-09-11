defmodule Fox.Accounts.Service.BalanceDevelopment do
  alias Fox.DateHelper

  def call(current_amount, transactions, range) do
    today = Clock.today()
    range_end = DateHelper.first(today, range.last)
    new_range = Date.range(range.first, range_end)
    nil_range = range_end |> Date.range(range.last)

    current_amount
    |> build_balance_range(transactions, new_range)
    |> prepend_nils(nil_range)
    |> Enum.reverse()
  end

  defp build_balance_range(current_amount, transactions, %{first: last, last: last}) do
    {sum, _} = sum_until(current_amount, transactions, last)
    [sum]
  end

  defp build_balance_range(current_amount, transactions, %{first: first, last: last}) do
    {sum, remaining_transactions} = sum_until(current_amount, transactions, last)
    next_range = Date.range(first, Date.add(last, -1))
    [sum | build_balance_range(sum, remaining_transactions, next_range)]
  end

  defp prepend_nils(amounts, range) do
    nil
    |> List.duplicate(Enum.count(range) - 1)
    |> Enum.reduce(amounts, fn _, amounts -> [nil | amounts] end)
  end

  defp sum_until(current_amount, transactions, date) do
    {transactions, remaining_transactions} =
      Enum.split_while(transactions, &DateHelper.after?(&1.transaction_date, date))

    amounts = transactions |> Enum.map(& &1.amount)

    sum =
      case amounts do
        [] ->
          current_amount

        amounts ->
          amounts
          |> Money.sum()
          |> then(fn {:ok, sum} -> Money.sub!(current_amount, sum) end)
      end

    {sum, remaining_transactions}
  end
end
