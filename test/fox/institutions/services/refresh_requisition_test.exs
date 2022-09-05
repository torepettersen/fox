defmodule Fox.Institutions.Service.RefreshRequisitionTest do
  use Fox.DataCase, async: true

  alias Fox.Institutions.Service.RefreshRequisition
  alias Fox.Institutions.Requisition
  alias Fox.Nordigen

  setup do
    bypass = setup_bypass(Nordigen, :client)

    user = insert(:user)
    Repo.put_user(user)

    %{
      requisition_id: nordigen_requisition_id,
      account_id: nordigen_account_id,
      transaction_id: transaction_id
    } = mock(bypass, :fetch_requisition_with_account_data)

    %{
      user: user,
      nordigen_requisition_id: nordigen_requisition_id,
      nordigen_account_id: nordigen_account_id,
      transaction_id: transaction_id
    }
  end

  test "refreshes requisition", %{nordigen_requisition_id: nordigen_requisition_id, user: user} do
    requisition = insert(:requisition, user: user, nordigen_id: nordigen_requisition_id)

    {:ok, attrs} = Nordigen.fetch_requisition(requisition.nordigen_id)
    status = Nordigen.map_requisition_status(attrs["status"])

    requisition_attrs = %{
      status: status,
      user_id: user.id
    }

    accounts_attrs = %{
      interim_available_amount: Money.from_float(:NOK, 52_442.85),
      expected_amount: Money.from_float(:NOK, 52_442.85),
      user_id: user.id
    }

    assert {:ok, %Requisition{} = requisition} = RefreshRequisition.call(requisition)
    assert_maps_equal(requisition, requisition_attrs, Map.keys(requisition_attrs))

    requisition = Repo.preload(requisition, accounts: :transactions)
    assert_maps_equal(List.first(requisition.accounts), accounts_attrs, Map.keys(accounts_attrs))
  end

  test "update existing accounts", ctx do
    %{
      nordigen_requisition_id: nordigen_requisition_id,
      nordigen_account_id: nordigen_account_id,
      transaction_id: transaction_id
    } = ctx

    requisition = insert(:requisition, nordigen_id: nordigen_requisition_id)

    account =
      %{id: account_id, name: account_name} =
      insert(:account, nordigen_id: nordigen_account_id, requisition: requisition)

    %{transaction_id: transaction_id} =
      insert(:transaction, transaction_id: transaction_id, account: account)

    assert {:ok, %Requisition{accounts: accounts}} = RefreshRequisition.call(requisition)
    assert [%{id: ^account_id, name: ^account_name, transactions: transactions}] = accounts
    assert [%{transaction_id: ^transaction_id}] = transactions
  end
end
