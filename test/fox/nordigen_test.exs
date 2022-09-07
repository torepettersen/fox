defmodule Fox.NordigenTest do
  use Fox.DataCase, async: true

  alias Fox.Nordigen

  setup do
    bypass = Bypass.open()
    set_bypass(bypass)
    %{bypass: bypass}
  end

  test "list_institutions/1", %{bypass: bypass} do
    mock(bypass, :list_institutions)
    assert {:ok, [%{} | _]} = Nordigen.list_institutions(%{country: "no"})
  end

  describe "fetch_requisition/1" do
    test "fetches the requisition", %{bypass: bypass} do
      id = mock(bypass, :fetch_requisition)
      {:ok, %{"id" => ^id}} = Nordigen.fetch_requisition(id)
    end

    test "returns error if not found", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/requisitions/wrong_id/", fn conn ->
        mock(conn, :not_found)
      end)

      {:error, :not_found} = Nordigen.fetch_requisition("wrong_id")
    end
  end

  describe "create_requisition/1" do
    setup %{bypass: bypass} do
      institution_id = "NORWEGIAN_NO_NORWNOK1"
      mock(bypass, :create_requisition, institution_id: institution_id)
      %{institution_id: institution_id}
    end

    test "creates requisition", %{institution_id: institution_id} do
      assert {:ok, %{"institution_id" => ^institution_id}} =
               Nordigen.create_requisition(%{
                 institution_id: institution_id,
                 redirect: "http://localhost:3000/banks"
               })
    end

    test "returns error when paramters is missing" do
      assert {:error, %{}} = Nordigen.create_requisition(%{})
    end

    test "returns error with invalid institution_id" do
      assert {:error, %{}} =
               Nordigen.create_requisition(%{institution_id: "123", redirect: "http://localhost"})
    end
  end

  describe "fetch_account_details/1" do
    test "fetches account details", %{bypass: bypass} do
      id = mock(bypass, :fetch_account_details)
      {:ok, %{"iban" => _}} = Nordigen.fetch_account_details(id)
    end

    test "returns error if not found", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/accounts/wrong_id/details/", fn conn ->
        mock(conn, :not_found)
      end)

      {:error, :not_found} = Nordigen.fetch_account_details("wrong_id")
    end
  end

  describe "fetch_account_balances/1" do
    test "fetches account balances", %{bypass: bypass} do
      id = mock(bypass, :fetch_account_balances)
      {:ok, [%{"balanceAmount" => _}, _, _]} = Nordigen.fetch_account_balances(id)
    end

    test "returns error if not found", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/accounts/wrong_id/balances/", fn conn ->
        mock(conn, :not_found)
      end)

      {:error, :not_found} = Nordigen.fetch_account_balances("wrong_id")
    end
  end

  test "fetch_account_transactions/1", %{bypass: bypass} do
    id = mock(bypass, :fetch_account_transactions)

    {:ok,
     [
       %{"transactionId" => _, "status" => "booked"}
     ]} = Nordigen.fetch_account_transactions(id)
  end
end
