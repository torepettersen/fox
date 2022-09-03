defmodule Fox.InstitutionsTest do
  use Fox.DataCase

  alias Fox.Institutions
  alias Fox.Repo

  describe "requisitions" do
    alias Fox.Institutions.Requisition

    @invalid_attrs %{institution_id: nil, link: nil, nordigen_id: nil, status: nil}

    setup do
      user = insert(:user)
      requisition = insert(:requisition, user: user)
      Repo.put_user(user)
      %{requisition: requisition, user: user}
    end

    test "list_requisitions/1 returns all requisitions", %{requisition: %{id: id}} do
      assert [%Requisition{id: ^id}] = Institutions.list_requisitions()
    end

    test "fetch_requisition/1 returns the requisition with given id", %{requisition: %{id: id}} do
      assert {:ok, %Requisition{id: ^id}} = Institutions.fetch_requisition(id)
    end

    test "fetch_requisition/1 returns error of not found" do
      assert {:error, :not_found} = Institutions.fetch_requisition(Ecto.UUID.generate())
    end

    test "fetch_requisition_by/1 returns the requisition with given id", %{requisition: %{id: id}} do
      assert {:ok, %Requisition{id: ^id}} = Institutions.fetch_requisition_by(id: id)
    end

    test "fetch_requisition_by/1 returns error of not found" do
      assert {:error, :not_found} = Institutions.fetch_requisition_by(id: Ecto.UUID.generate())
    end

    test "create_requisition/1 with valid data creates a requisition" do
      attrs = params_with_assocs(:requisition)
      assert {:ok, %Requisition{} = requisition} = Institutions.create_requisition(attrs)
      assert_maps_equal(requisition, attrs, Map.keys(attrs))
    end

    test "create_requisition/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Institutions.create_requisition(@invalid_attrs)
    end

    test "update_requisition/2 with valid data updates the requisition", %{
      requisition: requisition
    } do
      attrs = %{
        institution_id: "some updated institution_id",
        link: "some updated link",
        nordigen_id: "some updated nordigen_id",
        status: "some updated status"
      }

      assert {:ok, %Requisition{} = requisition} =
               Institutions.update_requisition(requisition, attrs)

      assert_maps_equal(requisition, attrs, Map.keys(attrs))
    end

    test "update_requisition/2 with invalid data returns error changeset", %{
      requisition: requisition
    } do
      assert {:error, %Ecto.Changeset{}} =
               Institutions.update_requisition(requisition, @invalid_attrs)

      assert_fields_equal(requisition, reload!(requisition))
    end

    test "delete_requisition/1 deletes the requisition", %{requisition: requisition} do
      assert {:ok, %Requisition{}} = Institutions.delete_requisition(requisition)
      assert_raise Ecto.NoResultsError, fn -> reload!(requisition) end
    end

    test "change_requisition/1 returns a requisition changeset", %{requisition: requisition} do
      assert %Ecto.Changeset{} = Institutions.change_requisition(requisition)
    end

    test "requisitions_count_and_last_updated/0 count and returns oldest last_updated" do
      now = DateTime.utc_now()
      in_the_past = DateTime.add(now, -3600)

      user = insert(:user)
      Repo.put_user(user)

      insert(:requisition, last_updated: now, user: user)
      insert(:requisition, last_updated: in_the_past, user: user)
      insert(:requisition, last_updated: nil, user: user)

      assert %{count: 3, last_updated: ^in_the_past} =
               Institutions.requisitions_count_and_last_updated()
    end

    test "requisitions_count_and_last_updated/0 count 0 and returns nil value for last_updated" do
      user = insert(:user)
      Repo.put_user(user)

      assert %{count: 0, last_updated: nil} = Institutions.requisitions_count_and_last_updated()
    end
  end
end
