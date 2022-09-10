defmodule Fox.Accounts.Services.BalanceDevelopmentTest do
  use Fox.DataCase, async: true

  alias Fox.Accounts.Service.BalanceDevelopment

  test "call/2" do
    transactions = [
      build(:transaction, amount: amount(-10_00), transaction_date: ~D[2022-09-04]),
      build(:transaction, amount: amount(10_00), transaction_date: ~D[2022-09-03]),
      build(:transaction, amount: amount(-10_00), transaction_date: ~D[2022-09-02]),
      build(:transaction, amount: amount(-10_00), transaction_date: ~D[2022-09-02]),
      build(:transaction, amount: amount(-10_00), transaction_date: ~D[2022-09-01])
    ]

    range = Date.range(~D[2022-09-01], ~D[2022-09-03])

    expected = [amount(120_00), amount(100_00), amount(110_00)]

    assert BalanceDevelopment.call(amount(100_00), transactions, range) == expected
  end

  defp amount(amount), do: Money.new(amount, :NOK)
end
