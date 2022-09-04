defmodule FoxWeb.AccountLive do
  use FoxWeb, :live_view

  alias Fox.Accounts

  def mount(%{"id" => id}, _session, socket) do
    {:ok, account} = Accounts.fetch_account(id)
    socket = assign(socket, account: account)

    {:ok, socket}
  end
end
