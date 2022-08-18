defmodule FoxWeb.ButtonComponent do
  use FoxWeb, :component

  @base_style "group inline-flex items-center justify-center rounded-full py-2 px-4 text-sm font-semibold focus:outline-none focus-visible:outline-2 focus-visible:outline-offset-2"
  @variant_style "bg-blue-600 text-white hover:text-slate-100 hover:bg-blue-500 active:bg-blue-800 active:text-blue-100 focus-visible:outline-blue-600"

  def button(assigns) when is_map_key(assigns, :href) or is_map_key(assigns, :navigate) do
    rest =
      assigns
      |> Map.drop([:__changed__, :inner_block])
      |> Enum.to_list()

    ~H"""
    <.link class={class(assigns)} {rest}>
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  def button(assigns) do
    ~H"""
    <button class={class(assigns)}>
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  defp class(assigns) do
    class = Access.get(assigns, :class)
    Enum.join([@base_style, @variant_style, class], " ")
  end
end
