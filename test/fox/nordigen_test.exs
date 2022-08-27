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
end
