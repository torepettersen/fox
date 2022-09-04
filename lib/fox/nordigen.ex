defmodule Fox.Nordigen do
  use Mockable.Decorator
  alias Fox.Nordigen.ClientServer

  require Logger

  def list_institutions(attrs) do
    attrs
    |> Map.take([:country])
    |> get("/institutions/")
  end

  def fetch_requisition(id) when is_binary(id) do
    get("/requisitions/#{id}/")
  end

  def create_requisition(attrs) do
    attrs
    |> Map.take([:institution_id, :redirect])
    |> post("/requisitions/")
  end

  def delete_requisition(id) when is_binary(id) do
    delete("/requisitions/#{id}/")
  end

  def fetch_account_details(id) when is_binary(id) do
    case get("/accounts/#{id}/details/") do
      {:ok, %{"account" => account}} -> {:ok, account}
      error -> error
    end
  end

  def fetch_account_balances(id) when is_binary(id) do
    case get("/accounts/#{id}/balances/") do
      {:ok, %{"balances" => balances}} -> {:ok, balances}
      error -> error
    end
  end

  def fetch_account_transactions(id) when is_binary(id) do
    case get("/accounts/#{id}/transactions/") do
      {:ok, %{"transactions" => transactions}} -> {:ok, flatten_transactions(transactions)}
      error -> error
    end
  end

  defp flatten_transactions(transactions) do
    Enum.flat_map(transactions, fn {status, transactions} ->
      Enum.map(transactions, &Map.put(&1, "status", status))
    end)
  end

  def fetch_requisition_with_account_data(id) when is_binary(id) do
    with {:ok, requisition} <- fetch_requisition(id),
         {:ok, accounts} <- fetch_account_data(requisition["accounts"]) do
      requisition = Map.put(requisition, "accounts", accounts)

      {:ok, requisition}
    end
  end

  def fetch_account_data(ids) do
    Enum.reduce_while(ids, {:ok, []}, fn account_id, {:ok, accounts} ->
      with {:ok, details} <- fetch_account_details(account_id),
           {:ok, balances} <- fetch_account_balances(account_id),
           {:ok, transactions} <- fetch_account_transactions(account_id) do
        account =
          details
          |> Map.put("id", account_id)
          |> Map.put("balances", balances)
          |> Map.put("transactions", transactions)

        {:cont, {:ok, [account | accounts]}}
      else
        error -> {:halt, error}
      end
    end)
  end

  # https://nordigen.com/en/account_information_documenation/integration/statuses/
  def map_requisition_status("CR"), do: "created"
  def map_requisition_status("GC"), do: "giving_consent"
  def map_requisition_status("UA"), do: "undergoing_authentication"
  def map_requisition_status("RJ"), do: "rejected"
  def map_requisition_status("SA"), do: "selecting_accounts"
  def map_requisition_status("GA"), do: "granting_access"
  def map_requisition_status("LN"), do: "linked"
  def map_requisition_status("SU"), do: "suspended"
  def map_requisition_status("EX"), do: "expired"
  def map_requisition_status(status), do: status

  defp get(params \\ %{}, path) do
    client()
    |> Req.get(url: path, params: params)
    |> handle_result(fn -> get(params, path) end)
  end

  defp post(params, path) do
    client()
    |> Req.post(url: path, json: params)
    |> handle_result(fn -> post(params, path) end)
  end

  defp delete(path) do
    client()
    |> Req.delete(url: path)
    |> handle_result(fn -> delete(path) end)
  end

  defp handle_result({:ok, %{status: status, body: body}}, _retry) when status in [200, 201],
    do: {:ok, body}

  defp handle_result({:ok, %{status: 400, body: body}}, _retry), do: {:error, body}
  defp handle_result({:ok, %{status: 404}}, _retry), do: {:error, :not_found}

  defp handle_result({:ok, %{status: 401}}, retry) do
    ClientServer.refresh_client()
    retry.()
  end

  defp handle_result(error, _retry) do
    Logger.error("Failed to fetch from Nordigen: #{inspect(error)}")
    {:error, :unknown_error}
  end

  @decorate mockable()
  def client do
    ClientServer.client()
  end
end
