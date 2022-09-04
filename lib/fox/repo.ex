defmodule Fox.Repo do
  use Ecto.Repo,
    otp_app: :fox,
    adapter: Ecto.Adapters.Postgres

  require Ecto.Query

  @user_key {__MODULE__, :user}

  defguard schema_in_query?(query, module) when elem(query.from.source, 1) == module

  @impl true
  def prepare_query(operation, query, opts) do
    schema = elem(query.from.source, 1)

    if opts[:skip_policy] || opts[:schema_migration] do
      {query, opts}
    else
      schema.restrict(operation, query, opts)
    end
  end

  @impl true
  def default_options(_operation) do
    [user_id: get_user_id()]
  end

  def wrap_result(nil = _result), do: {:error, :not_found}
  def wrap_result(result), do: {:ok, result}

  @type ok_or_error :: {:ok, any()} | {:error, any()}
  @type summarize_result :: %{ok: integer(), error: integer(), errors: [{:error, any()}]}

  @spec summarize_results([ok_or_error()]) :: summarize_result()
  def summarize_results(results) do
    Enum.reduce(results, %{ok: 0, error: 0, errors: []}, fn result, acc ->
      case result do
        {:ok, _} ->
          Map.update!(acc, :ok, &(&1 + 1))

        {:error, _} = error ->
          acc
          |> Map.update!(:error, &(&1 + 1))
          |> Map.update!(:errors, &[error | &1])
      end
    end)
  end

  def put_user(user) do
    Process.put(@user_key, user)
  end

  def get_user do
    Process.get(@user_key)
  end

  def get_user_id do
    case get_user() do
      %{id: id} -> id
      _ -> nil
    end
  end
end
