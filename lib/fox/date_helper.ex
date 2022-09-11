defmodule Fox.DateHelper do
  @doc """
  Returns end of last month

    iex> end_of_last_month(~D[2022-09-09])
    ~D[2022-08-31]
  """
  @spec end_of_last_month(Date.t()) :: Date.t()
  def end_of_last_month(date) do
    date |> Date.beginning_of_month() |> Date.add(-1)
  end

  @doc """
  Returns a boolean indicating whether the first occurs after the second

    iex> after?(~D[2022-09-01], ~D[2022-08-31])
    true

    iex> after?(~D[2022-09-01], ~D[2022-09-01])
    false

    iex> after?(~D[2022-09-01], ~D[2022-09-02])
    false
  """
  @spec after?(Date.t(), Date.t()) :: boolean()
  def after?(a, b) do
    case Date.compare(a, b) do
      :gt -> true
      _ -> false
    end
  end

  @doc """
  Function for returning the first of two dates.

  # Examples:
    iex> first(~D[2022-01-01], ~D[2022-01-02])
    ~D[2022-01-01]

    iex> first(~D[2022-01-01], ~D[2021-12-31])
    ~D[2021-12-31]

    iex> first(~D[2022-01-01], ~D[2021-01-01])
    ~D[2021-01-01]
  """
  @spec first(Date.t(), Date.t()) :: Date.t()
  def first(date1, date2) do
    case Date.compare(date1, date2) do
      :lt -> date1
      _ -> date2
    end
  end

  @doc """
  Function for returning the last of two dates.

  # Examples:
    iex> last(~D[2022-01-01], ~D[2022-01-02])
    ~D[2022-01-02]

    iex> last(~D[2022-01-01], ~D[2021-12-31])
    ~D[2022-01-01]

    iex> last(~D[2022-01-01], ~D[2021-01-01])
    ~D[2022-01-01]
  """
  @spec last(Date.t(), Date.t()) :: Date.t()
  def last(date1, date2) do
    case Date.compare(date1, date2) do
      :gt -> date1
      _ -> date2
    end
  end
end
