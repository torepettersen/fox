defmodule Fox.NordigenTest do
  use Fox.DataCase, async: true

  alias Fox.Nordigen
  alias Mockable

  setup do
    bypass = setup_bypass(Nordigen, :client)
    %{bypass: bypass}
  end

  test "list_institutions/1", %{bypass: bypass} do
    mock(bypass, :list_institutions)
    assert {:ok, [%{} | _]} = Nordigen.list_institutions(%{country: "no"})
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
end
