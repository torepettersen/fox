defmodule Fox.DateHelper do
  @doc """
  Returns end of last month

    iex> DateHelper.end_of_last_month(~D[2022-09-09])
    ~D[2022-08-31]
  """
  def end_of_last_month(date) do
    date |> Date.beginning_of_month() |> Date.add(-1)
  end

  @doc """
  Returns a boolean indicating whether the first occurs after the second

    iex> DateHelper.after?(~D[2022-09-01], ~D[2022-08-31])
    true

    iex> DateHelper.after?(~D[2022-09-01], ~D[2022-09-01])
    false

    iex> DateHelper.after?(~D[2022-09-01], ~D[2022-09-02])
    false
  """
  def after?(a, b) do
    case Date.compare(a, b) do
      :gt -> true
      _ -> false
    end
  end
end
