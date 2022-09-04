defmodule Fox.Institutions.Service.RefreshRequisitionsTest do
  use Fox.DataCase, async: true

  alias Fox.Institutions.Service.RefreshRequisitions
  alias Fox.Nordigen

  setup do
    bypass = setup_bypass(Nordigen, :client)
    %{bypass: bypass}
  end

  test "refresh requistions for user", %{bypass: bypass} do
    user = insert(:user)
    Repo.put_user(user)
    nordigen_id = mock(bypass, :fetch_requisition, accounts: [])
    insert(:requisition, user: user, nordigen_id: nordigen_id)

    assert RefreshRequisitions.call() == %{ok: 1, error: 0, errors: []}
  end
end
