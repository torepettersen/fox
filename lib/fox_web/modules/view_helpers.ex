defmodule FoxWeb.ViewHelpers do
  alias Fox.Accounts.Account
  alias FoxWeb.Endpoint
  alias FoxWeb.Router.Helpers, as: Routes

  def live_path(live_view) do
    Routes.live_path(Endpoint, live_view)
  end

  def live_path(live_view, arg) do
    Routes.live_path(Endpoint, live_view, arg)
  end

  def format_account_number(%Account{iban: iban}), do: format_account_number(iban)

  def format_account_number("NO" <> _ = iban) do
    Regex.replace(~r/^(.{4})(\d{4})(\d{2})(\d{5})$/, iban, "\\2.\\3.\\4")
  end

  def format_account_number(iban), do: iban

  @default_opts [fractional_digits: 0, rounding_mode: :down]
  def format_amount(money, opts \\ [])

  def format_amount(%Account{interim_available_amount: amount}, opts) do
    format_amount(amount, opts)
  end

  def format_amount(%Money{} = money, opts) do
    opts = Keyword.merge(@default_opts, opts)

    case opts[:show_currency] do
      false -> format_amount(money.amount, opts)
      _ -> format_money(money, opts)
    end
  end

  def format_amount(amount, opts) do
    case Fox.Cldr.Number.to_string(amount, opts) do
      {:ok, amount} -> amount
      _ -> ""
    end
  end

  defp format_money(%Money{} = money, opts) do
    case Money.to_string(money, opts) do
      {:ok, amount} -> amount
      _ -> ""
    end
  end
end
