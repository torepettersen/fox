defmodule FoxWeb.TransactionsComponent do
  use FoxWeb, :component

  attr :transactions, :list

  def transactions(assigns) do
    ~H"""
    <div class="space-y-6">
      <h2 class="text-lg">Transactions</h2>
      <div class="grid gap-4 grid-cols-[fit-content(10%)_minmax(0,_1fr)_fit-content(15%)]">
        <%= for transaction <- @transactions do %>
          <.transaction transaction={transaction} />
        <% end %>
      </div>
    </div>
    """
  end

  defp transaction(assigns) do
    ~H"""
        <div class="flex flex-col w-fit text-center">
          <span class="text-xs leading-none"><%= day_of_week(@transaction.transaction_date) %></span>
          <span class="text-lg font-semibold tracking-widest leading-none"><%= @transaction.transaction_date.day %></span>
        </div>
        <div class="flex items-center">
          <span class="text-[11px] leading-tight line-clamp-2"><%= @transaction.additional_information %></span>
        </div>
      <div class="flex items-center justify-end">
        <span class="text-xs font-semibold h-fit self-right"><%= format_amount(@transaction.amount, show_currency: false, fractional_digits: 2) %></span>
      </div>
    """
  end
end
