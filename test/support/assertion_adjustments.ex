defmodule Fox.AssertionAdjustments do
  require Assertions

  def assert_lists_contain_same(list_a, list_b) do
    Assertions.assert_lists_equal(list_a, list_b)
  end

  def assert_lists_contain_same(list_a, list_b, comparison) do
    Assertions.assert_lists_equal(list_a, list_b, comparison)
  end

  def assert_fields_equal(%{__struct__: struct} = a, %{__struct__: struct} = b) do
    keys = struct.__schema__(:fields)
    Assertions.assert_maps_equal(a, b, keys)
  end
end
