defmodule FoxWeb.LinkComponent do
  use FoxWeb, :component

  def link(%{href: href} = assigns) do
    args =
      assigns
      |> Map.drop([:__changed__, :href, :inner_block])
      |> Enum.to_list()
      |> then(&[{:to, href} | &1])

    ~H"""
    <%= link args do %>
      <%= render_slot(@inner_block) %>
    <% end %>
    """
  end

  def link(%{navigate: to} = assigns) do
    args =
      assigns
      |> Map.drop([:__changed__, :navigate, :inner_block])
      |> Enum.to_list()
      |> then(&[{:to, to} | &1])

    ~H"""
    <%= live_redirect args do %>
      <%= render_slot(@inner_block) %>
    <% end %>
    """
  end
end
