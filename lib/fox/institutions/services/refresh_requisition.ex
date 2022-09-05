defmodule Fox.Institutions.Service.RefreshRequisition do
  alias Fox.Nordigen
  alias Fox.Institutions
  alias Fox.Institutions.Requisition
  alias Fox.Repo

  @spec call(Requisition.t() | String.t()) :: {:ok, Requisition.t()}
  def call(id) when is_binary(id) do
    with {:ok, requisition} <- Institutions.fetch_requisition(id) do
      call(requisition)
    end
  end

  def call(%Requisition{nordigen_id: nordigen_id} = requisition) do
    with {:ok, attrs} <- Nordigen.fetch_requisition_with_account_data(nordigen_id) do
      requisition = Repo.reload!(requisition)
      requisition = Repo.preload(requisition, accounts: :transactions)

      attrs = build_requisition(attrs, requisition.accounts)

      Institutions.update_requisition(requisition, attrs)
    end
  end

  defp build_requisition(requisition, exsisting_accounts) do
    status = Nordigen.map_requisition_status(requisition["status"])
    accounts = Enum.map(requisition["accounts"], &build_account(&1, exsisting_accounts))

    %{
      status: status,
      link: requisition["link"],
      accounts: accounts,
      last_updated: DateTime.utc_now()
    }
  end

  defp build_account(account, exsisting_accounts) do
    exsisting_account = Enum.find(exsisting_accounts, %{}, &(&1.nordigen_id == account["id"]))
    exsisting_account_attrs = Map.take(exsisting_account, [:id, :name, :account_group])

    transactions =
      account["transactions"]
      |> transactions_to_map()
      |> build_transactions(Map.get(exsisting_account, :transactions, []))

    attrs = %{
      name: account["name"],
      iban: account["iban"],
      bban: account["bban"],
      bic: account["bic"],
      interim_available_amount: find_balance_by_type(account["balances"], "interimAvailable"),
      expected_amount: find_balance_by_type(account["balances"], "expected"),
      currency: account["currency"],
      owner_name: account["ownerName"],
      nordigen_id: account["id"],
      transactions: transactions
    }

    Map.merge(attrs, exsisting_account_attrs)
  end

  defp build_transactions([] = _transactions, [] = _exsisting_transactions), do: []

  defp build_transactions(transactions, [exsisting | tail] = _exsisting_transactions) do
    {transaction, transactions} = Map.pop(transactions, exsisting.transaction_id)
    [build_transaction(transaction, exsisting) | build_transactions(transactions, tail)]
  end

  defp build_transactions(%{} = transactions, [] = _exsisting_transactions) do
    transactions
    |> Map.values()
    |> Enum.map(&build_transaction(&1, nil))
  end

  defp build_transaction(nil, exsisting_transaction) when not is_nil(exsisting_transaction) do
    exsisting_transaction
  end

  defp build_transaction(transaction, exsisting_transaction) do
    %{"amount" => amount, "currency" => currency} = transaction["transactionAmount"]

    attrs = %{
      status: String.to_atom(transaction["status"]),
      transaction_id: transaction["transactionId"],
      booking_date: transaction["bookingDate"],
      transaction_date: transaction["valueDate"],
      amount: Money.parse(amount, default_currency: currency),
      additional_information: transaction["additionalInformation"]
    }

    case exsisting_transaction do
      nil -> attrs
      transaction -> transaction |> Map.take([:id]) |> Map.merge(attrs)
    end
  end

  defp transactions_to_map(transactions) do
    for transaction <- transactions, into: %{} do
      {transaction["transactionId"], transaction}
    end
  end

  defp find_balance_by_type(balances, type) do
    case Enum.find(balances, &(&1["balanceType"] == type)) do
      %{"balanceAmount" => %{"amount" => amount, "currency" => currency}} ->
        Money.parse(amount, default_currency: currency)

      _ ->
        nil
    end
  end
end
