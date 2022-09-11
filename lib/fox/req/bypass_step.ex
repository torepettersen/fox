defmodule Req.BypassStep do
  unless Mix.env() == :test do
    def run_bypass(request), do: request
  else
    def run_bypass(request) do
      if bypass = pdict_get() || agent_get() do
        base_url = "http://localhost:#{bypass.port}"
        put_in(request, [Access.key(:options), :base_url], base_url)
      else
        raise "Bypass not setup"
      end
    end

    def set_bypass(bypass) do
      pdict_set(bypass)
    end

    def set_bypass_global(bypass) do
      agent_set(bypass)
    end

    defp pdict_set(bypass), do: Process.put(__MODULE__, bypass)
    defp pdict_get, do: Process.get(__MODULE__)

    defp agent_set(bypass) do
      case Process.whereis(__MODULE__) do
        nil ->
          ExUnit.Callbacks.start_supervised!(
            %{
              id: __MODULE__,
              start: {Agent, :start_link, [fn -> bypass end, [{:name, __MODULE__}]]}
            },
            []
          )

        pid ->
          Agent.update(pid, fn _ -> bypass end)
      end
    end

    defp agent_get do
      case Process.whereis(__MODULE__) do
        nil -> nil
        pid -> Agent.get(pid, fn f -> f end)
      end
    end
  end
end
