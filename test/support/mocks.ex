defmodule Fox.Mocks do
  alias Plug.Conn
  def mock(bypass_or_conn, function, attrs \\ [])

  def mock(%Conn{} = conn, :not_found, _attrs) do
    json(
      conn,
      %{
        summary: "Not found.",
        detail: "Not found.",
        status_code: 404
      },
      status: 404
    )
  end

  def mock(%Bypass{} = bypass, :list_institutions, _attrs) do
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

  def mock(%Bypass{} = bypass, :fetch_requisition, attrs) do
    id = Keyword.get_lazy(attrs, :id, fn -> Ecto.UUID.generate() end)

    accounts =
      Keyword.get_lazy(attrs, :accounts, fn ->
        Enum.map(1..5, fn _ -> Ecto.UUID.generate() end)
      end)

    Bypass.expect(bypass, "GET", "/requisitions/#{id}", fn conn ->
      json(conn, %{
        id: id,
        created: "2022-04-23T21:56:00.931939Z",
        redirect: "http://localhost:3000/banks",
        status: "LN",
        institution_id: "DNB_DNBANOKK",
        agreement: "79e1a956-9435-4b24-b4b8-bcbb1dda4740",
        reference: "22e23466-48b8-4599-8a13-7600754fc83f",
        accounts: accounts,
        link:
          "https://ob.nordigen.com/psd2/start/22e23466-48b8-4599-8a13-7600754fc83f/DNB_DNBANOKK",
        ssn: nil,
        account_selection: false,
        redirect_immediate: false
      })
    end)

    id
  end

  def mock(%Bypass{} = bypass, :create_requisition, attrs) do
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

  def mock(%Bypass{} = bypass, :fetch_account_details, attrs) do
    id = Keyword.get_lazy(attrs, :id, fn -> Ecto.UUID.generate() end)

    Bypass.expect(bypass, "GET", "/accounts/#{id}/details", fn conn ->
      json(conn, %{
        account: %{
          iban: "NO5812256448643",
          bban: "12256448643",
          currency: "NOK",
          ownerName: "Tore Skog Pettersen",
          name: "BRUKSKONTO",
          bic: "DNBANOKKXXX"
        }
      })
    end)

    id
  end

  def mock(%Bypass{} = bypass, :fetch_account_balances, attrs) do
    id = Keyword.get_lazy(attrs, :id, fn -> Ecto.UUID.generate() end)

    Bypass.expect(bypass, "GET", "/accounts/#{id}/balances/", fn conn ->
      json(conn, %{
        balances: [
          %{balanceAmount: %{amount: "52442.85", currency: "NOK"}, balanceType: "openingBooked"},
          %{
            balanceAmount: %{amount: "52442.85", currency: "NOK"},
            balanceType: "interimAvailable"
          },
          %{balanceAmount: %{amount: "52442.85", currency: "NOK"}, balanceType: "expected"}
        ]
      })
    end)

    id
  end

  def mock(%Bypass{} = bypass, :fetch_account_transactions, attrs) do
    id = Keyword.get_lazy(attrs, :id, fn -> Ecto.UUID.generate() end)
    transaction_id = Keyword.get(attrs, :transaction_id, "0116_0021893786078_0000001")

    Bypass.expect(bypass, "GET", "/accounts/#{id}/transactions/", fn conn ->
      json(conn, %{
        "transactions" => %{
          "booked" => [
            %{
              "transactionId" => transaction_id,
              "bookingDate" => "2022-09-01",
              "valueDate" => "2022-09-01",
              "transactionAmount" => %{
                "amount" => "-1400.0",
                "currency" => "NOK"
              },
              "creditorAccount" => %{
                "bban" => "12256351771"
              },
              "debtorAccount" => %{
                "bban" => "12256448643"
              },
              "additionalInformation" => "Kontoregulering, Renovering"
            }
          ],
          "pending" => []
        }
      })
    end)

    id
  end

  def mock(%Bypass{} = bypass, :delete_requisition, attrs) do
    id = attrs[:id] || "7993ca30-8dd3-46cb-809f-eb7e7918e939"

    Bypass.expect(bypass, "DELETE", "/requisitions/#{id}/", fn conn ->
      json(conn, %{summary: "Requisition deleted"})
    end)
  end

  def mock(%Bypass{} = bypass, :fetch_requisition_with_account_data, _attrs) do
    transaction_id = "0116_0021893786076_0000001"
    account_id = mock(bypass, :fetch_account_details)
    mock(bypass, :fetch_account_balances, id: account_id)
    mock(bypass, :fetch_account_transactions, id: account_id, transaction_id: transaction_id)
    requisition_id = mock(bypass, :fetch_requisition, accounts: [account_id])

    %{requisition_id: requisition_id, account_id: account_id, transaction_id: transaction_id}
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
