defmodule FoxWeb.DiagonalBox do
  use FoxWeb, :component

  def diagonal_box(assigns) do
    ~H"""
    <div class="bg-gradient-to-tr from-blue-800 to-blue-500" style={diagonal_box_style()}>
      <div class="text-white" style={box_content_style()}>
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp diagonal_box_style do
    angle = 12
    magic_number = magic_number(angle)

    """
    --content-skew: #{angle}deg;
    --box-skew: calc(var(--content-skew) * -1);
    --content-width: 100%;
    --padding: calc(var(--content-width) * #{magic_number});
    --margin: calc(var(--padding) * -1);
    margin-top: var(--margin);
    margin-bottom: var(--padding);
    transform: skewy(var(--box-skew));
    height: 16rem;
    """
  end

  defp box_content_style do
    """
    padding-top: var(--padding);
    transform: skewY(var(--content-skew));
    """
  end

  defp magic_number(angle) do
    angle
    |> Kernel.*(:math.pi())
    |> Kernel./(180)
    |> :math.tan()
    |> Kernel./(2)
  end
end
