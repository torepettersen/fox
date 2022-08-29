defmodule Fox.Nordigen do
  use Mockable.Decorator
  alias Fox.Nordigen.ClientServer

  require Logger

  def list_institutions(attrs) do
    attrs
    |> Map.take([:country])
    |> get("/institutions/")
  end

  def create_requisition(attrs) do
    attrs
    |> Map.take([:institution_id, :redirect])
    |> post("/requisitions/")
  end

  defp get(params, path) do
    client()
    |> Req.get(url: path, params: params)
    |> handle_result(fn -> get(params, path) end)
  end

  defp post(params, path) do
    client()
    |> Req.post(url: path, params: params)
    |> handle_result(fn -> get(params, path) end)
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
