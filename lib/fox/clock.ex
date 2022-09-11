defmodule Clock do
  unless Mix.env() == :test do
    def today, do: Date.utc_today()
    def now, do: DateTime.utc_now()
  else
    def today do
      if now = pdict_get() || agent_get() do
        DateTime.to_date(now)
      else
        raise "Time not setup"
      end
    end

    def now do
      if now = pdict_get() || agent_get() do
        DateTime.to_date(now)
      else
        raise "Time not setup"
      end
    end

    def set(date = %Date{}) do
      date |> DateTime.new!(~T[00:00:00]) |> pdict_set()
    end

    def set(now = %DateTime{}), do: pdict_set(now)

    def set_global(date = %Date{}) do
      date |> DateTime.new!(~T[00:00:00]) |> agent_set()
    end

    def set_global(now = %DateTime{}), do: agent_set(now)

    defp pdict_set(now), do: Process.put(__MODULE__, now)
    defp pdict_get, do: Process.get(__MODULE__)

    defp agent_set(now) do
      case Process.whereis(__MODULE__) do
        nil ->
          ExUnit.Callbacks.start_supervised!(
            %{
              id: __MODULE__,
              start: {Agent, :start_link, [fn -> now end, [{:name, __MODULE__}]]}
            },
            []
          )

        pid ->
          Agent.update(pid, fn _ -> now end)
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
