defmodule FoxWeb.BanksLive do
  use FoxWeb, :live_view

  alias Fox.Nordigen
  alias Fox.Institutions.Service.CreateRequisition
  alias Fox.Repo

  def mount(_params, _session, socket) do
    socket =
      assign_new(socket, :all_banks, fn ->
        {:ok, banks} = Nordigen.list_institutions(%{country: "no"})
        banks
      end)

    socket = assign(socket, banks: socket.assigns.all_banks)

    {:ok, socket}
  end

  def handle_event("query_banks", %{"params" => %{"query" => query}}, socket) do
    banks = Seqfuzz.filter(socket.assigns.all_banks, query, & &1["name"])
    socket = assign(socket, banks: banks)
    {:noreply, socket}
  end

  def handle_event("create_requisition", %{"key" => id}, socket) do
    {:ok, requisition} =
      CreateRequisition.call(%{
        institution_id: id,
        redirect: "http://localhost:4000",
        user: Repo.get_user()
      })

    socket = redirect(socket, external: requisition.link)

    {:noreply, socket}
  end
end
