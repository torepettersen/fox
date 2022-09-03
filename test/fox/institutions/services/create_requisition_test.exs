defmodule Fox.Institutions.Service.CreateRequisitionTest do
  use Fox.DataCase, async: true

  alias Ecto.Changeset
  alias Fox.Nordigen
  alias Fox.Institutions.Requisition
  alias Fox.Institutions.Service.CreateRequisition
  alias Fox.Repo

  setup do
    bypass = setup_bypass(Nordigen, :client)
    mock(bypass, :create_requisition, institution_id: "DNB")

    user = insert(:user)
    Repo.put_user(user)

    %{bypass: bypass}
  end

  test "creates requisition" do
    attrs = %{
      institution_id: "DNB",
      redirect: "http://localhost:4000",
      user: insert(:user)
    }

    assert {:ok, %Requisition{}} = CreateRequisition.call(attrs)
  end

  test "returns underlaying error" do
    assert {:error, _} = CreateRequisition.call(%{institution_id: "None exisiting"})
  end

  test "deletes requisition on failure", %{bypass: bypass} do
    mock(bypass, :delete_requisition)

    attrs = %{
      institution_id: "DNB",
      redirect: "http://localhost:4000",
      user: %{id: 1337}
    }

    assert {:error, %Changeset{}} = CreateRequisition.call(attrs)
  end
end
