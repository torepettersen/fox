defmodule FoxWeb.Components do
  defdelegate alert(assigns), to: FoxWeb.AlertComponent
  defdelegate button(assigns), to: FoxWeb.ButtonComponent
  defdelegate container(assigns), to: FoxWeb.ContainerComponent
  defdelegate form_input(assigns), to: FoxWeb.FormInputComponent
  defdelegate link(assigns), to: FoxWeb.LinkComponent
  defdelegate navbar(assigns), to: FoxWeb.NavbarComponent
  defdelegate notifications(assigns), to: FoxWeb.NotificationComponent
end
