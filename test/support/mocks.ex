defmodule Fox.Mocks do
  def mock(bypass_or_conn, function, attrs \\ [])

  def mock(bypass, :list_institutions, _attrs) do
    Bypass.expect(bypass, "GET", "/institutions/", fn conn ->
      json(conn, [
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
    end)
  end

  def mock(bypass, :create_requisition, attrs) do
    Bypass.expect(bypass, "POST", "/requisitions/", fn %{params: params} = conn ->
      reference = params["reference"] || Ecto.UUID.generate()
      id = attrs[:id] || "7993ca30-8dd3-46cb-809f-eb7e7918e939"
      institution_id = attrs[:institution_id] || "NORWEGIAN_NO_NORWNOK1"

      case read_body(conn) do
        %{"redirect" => redirect, "institution_id" => ^institution_id} ->
          json(conn, %{
            id: id,
            created: "2022-01-19T21:12:02.073920Z",
            redirect: redirect,
            status: "CR",
            institution_id: institution_id,
            agreement: "",
            reference: reference,
            accounts: [],
            user_language: "EN",
            link:
              "https://ob.nordigen.com/psd2/start/7993ca30-8dd3-46cb-809f-eb7e7918e939/#{institution_id}",
            ssn: nil,
            account_selection: false
          })

        %{"redirect" => _, "institution_id" => institution_id} ->
          json(
            conn,
            %{
              institution_id: %{
                summary: "Unknown Institution ID #{institution_id}",
                detail: "Get Institution IDs from /institutions/?country={$COUNTRY_CODE}"
              },
              status_code: 400
            },
            status: 400
          )

        _ ->
          json(
            conn,
            %{
              redirect: ["This field is required."],
              institution_id: ["This field is required."],
              status_code: 400
            },
            status: 400
          )
      end
    end)
  end

  def mock(bypass, :delete_requisition, attrs) do
    id = attrs[:id] || "7993ca30-8dd3-46cb-809f-eb7e7918e939"

    Bypass.expect(bypass, "DELETE", "/requisitions/#{id}/", fn conn ->
      json(conn, %{summary: "Requisition deleted"})
    end)
  end

  def setup_bypass(module, client) do
    bypass = Bypass.open()
    Mockable.expect(module, client, Req.new(base_url: endpoint_url(bypass.port)))
    bypass
  end

  defp json(conn, resp, attrs \\ []) do
    status = attrs[:status] || 200

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.resp(status, Jason.encode!(resp))
  end

  defp read_body(conn) do
    case Plug.Conn.read_body(conn) do
      {:ok, body, _conn} -> Jason.decode!(body)
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}/"
end
