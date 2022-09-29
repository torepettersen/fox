defmodule FoxWeb.FormInputComponent do
  use FoxWeb, :component

  attr :form, :any, required: true
  attr :field, :any, required: true
  attr :type, :atom, default: :text
  attr :label, :string

  def form_input(%{type: :checkbox} = assigns) do
    ~H"""
    <div class="flex items-center">
      <.input {assigns} />
      <.form_label {assigns} />
    </div>
    """
  end

  def form_input(assigns) do
    ~H"""
    <div class="space-y-1">
      <.form_label {assigns} />
      <.input {assigns} />
      <%= error_tag @form, @field %>
    </div>
    """
  end

  defp form_label(%{label: _label} = assigns) do
    ~H"""
    <%= label @form, @field, @label, class: "block text-sm font-medium text-gray-700" %>
    """
  end

  defp form_label(assigns) do
    ~H"""
    <%= label @form, @field, class: "block text-sm font-medium text-gray-700" %>
    """
  end

  defp input(%{type: :text} = assigns) do
    ~H"""
    <%= text_input @form, @field, input_assigns(assigns) %>
    """
  end

  defp input(%{type: :email} = assigns) do
    ~H"""
    <%= email_input @form, @field, input_assigns(assigns) %>
    """
  end

  defp input(%{type: :password} = assigns) do
    ~H"""
    <%= password_input @form, @field, input_assigns(assigns) %>
    """
  end

  defp input(%{type: :checkbox} = assigns) do
    ~H"""
    <%= checkbox @form, @field, input_assigns(assigns) %>
    """
  end

  defp input_style(%{type: :checkbox}) do
    "h-4 w-4 mr-2 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
  end

  defp input_style(_assigns) do
    "appearance-none block w-full px-3 py-2 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 text-sm"
  end

  defp input_assigns(assigns) do
    assigns
    |> Map.drop([:form, :field, :class])
    |> Map.put(:class, input_style(assigns))
    |> Enum.to_list()
  end
end
