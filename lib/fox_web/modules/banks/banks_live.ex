defmodule FoxWeb.BanksLive do
  use FoxWeb, :live_view

  alias Fox.Nordigen

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
    IO.inspect(id)
    {:noreply, socket}
  end
end
