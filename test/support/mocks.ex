defmodule Fox.Mocks do
  def mock(bypass, function, attrs \\ [])

  def mock(bypass, :list_institutions, _attrs) do
    json(bypass, [
      %{
        id: "DNB_DNBANOKK",
        name: "DNB",
        bic: "DNBANOKK",
        transaction_total_days: "395",
        countries: ["NO"],
        logo: "https://cdn.nordigen.com/ais/DNB_DNBANOKK.png"
      },
      %{
        id: "NORWEGIAN_NO_NORWNOK1",
        name: "Bank Norwegian",
        bic: "NORWNOK1",
        transaction_total_days: "730",
        countries: ["NO"],
        logo: "https://cdn.nordigen.com/ais/NORWEGIAN_FI_NORWNOK1.png"
      }
    ])
  end

  def setup_bypass(module, client) do
    bypass = Bypass.open()
    Mockable.expect(module, client, Req.new(base_url: endpoint_url(bypass.port)))
    bypass
  end

  defp json(bypass, resp) do
    Bypass.expect(bypass, fn conn ->
      conn
      |> Plug.Conn.put_resp_header("content-type", "application/json")
      |> Plug.Conn.resp(200, Jason.encode!(resp))
    end)
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
