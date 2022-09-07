defmodule Fox.NordigenSyncTest do
  use Fox.DataCase, async: false

  alias Fox.Nordigen

  setup do
    bypass = Bypass.open()
    set_bypass_global(bypass)
    %{bypass: bypass}
  end

  test "fetch_requisition_with_account_data/1", %{bypass: bypass} do
    account_id = mock(bypass, :fetch_account_details)
    mock(bypass, :fetch_account_balances, id: account_id)
    mock(bypass, :fetch_account_transactions, id: account_id)
    requisition_id = mock(bypass, :fetch_requisition, accounts: [account_id])

    assert {:ok, result} = Nordigen.fetch_requisition_with_account_data(requisition_id)

    assert %{
             "id" => ^requisition_id,
             "accounts" => [
               %{
                 "id" => ^account_id,
                 "iban" => _,
                 "balances" => [%{"balanceAmount" => _} | _],
                 "transactions" => [%{"transactionId" => _} | _]
               }
             ]
           } = result
  end
end
