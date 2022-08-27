defmodule Fox.Nordigen.ClientServer do
  use GenServer

  @me __MODULE__
  @base_url Application.get_env(:fox, :nordigen_base_url)
  @secret_id Application.get_env(:fox, :nordigen_secret_id)
  @secret_key Application.get_env(:fox, :nordigen_secret_key)
  @hour 60 * 60

  def client do
    GenServer.call(@me, :get_client)
  end

  def start_link(args) do
    GenServer.start_link(@me, args, name: @me)
  end

  @impl true
  def init(_args) do
    state = %{client: build_client()}
    {:ok, state}
  end

  def refresh_client do
    send(@me, :build_client)
  end

  @impl true
  def handle_call(:get_client, _from, %{client: client} = state) do
    {:reply, client, state}
  end

  @impl true
  def handle_info(:build_client, state) do
    Task.start_link(fn ->
      case fetch_token(state) do
        {:ok, %{body: %{"access" => token, "access_expires" => expires}}} ->
          send(@me, {:build_client, token, expires})

        _ ->
          Process.sleep(60_000)
          send(@me, :build_client)
      end
    end)

    {:noreply, state}
  end

  def handle_info({:build_client, token, expires}, state) do
    state = Map.put(state, :client, build_client(token))
    Process.send_after(@me, :build_client, (expires - @hour) * 1_000)
    {:noreply, state}
  end

  defp fetch_token(%{client: client}) do
    Req.post(client, url: "/token/new/", json: %{secret_id: @secret_id, secret_key: @secret_key})
  end

  defp build_client(token \\ nil)

  defp build_client(nil = _token) do
    Req.new(base_url: @base_url)
  end

  defp build_client(token) do
    Req.new(base_url: @base_url, auth: {:bearer, token})
  end
end
