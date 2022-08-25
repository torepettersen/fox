defmodule FoxWeb.Components do
  defdelegate alert(assigns), to: FoxWeb.AlertComponent
  defdelegate button(assigns), to: FoxWeb.ButtonComponent
  defdelegate container(assigns), to: FoxWeb.ContainerComponent
  defdelegate diagonal_box(assigns), to: FoxWeb.DiagonalBox
  defdelegate form_input(assigns), to: FoxWeb.FormInputComponent
  defdelegate image_list(assigns), to: FoxWeb.ImageList
  defdelegate link(assigns), to: FoxWeb.LinkComponent
  defdelegate navbar(assigns), to: FoxWeb.NavbarComponent
  defdelegate notifications(assigns), to: FoxWeb.NotificationComponent
end
