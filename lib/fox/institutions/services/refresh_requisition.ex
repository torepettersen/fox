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
      requisition = Repo.preload(requisition, :accounts)

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
    exsisting_account_attrs =
      exsisting_accounts
      |> Enum.find(%{}, &(&1.nordigen_id == account["id"]))
      |> Map.take([:id, :name, :account_group])

    attrs = %{
      name: account["name"],
      iban: account["iban"],
      bban: account["bban"],
      bic: account["bic"],
      interim_available_amount: find_balance_by_type(account["balances"], "interimAvailable"),
      expected_amount: find_balance_by_type(account["balances"], "expected"),
      currency: account["currency"],
      owner_name: account["ownerName"],
      nordigen_id: account["id"]
    }

    Map.merge(attrs, exsisting_account_attrs)
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
