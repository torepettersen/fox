defmodule Fox.Institutions.Service.CreateRequisition do
  import Sage
  alias Fox.Nordigen
  alias Fox.Institutions
  alias Fox.Institutions.Requisition
  alias Fox.Users.User
  alias Fox.Repo

  @type attrs :: %{
          institution_id: String.t(),
          redirect: String.t(),
          user: User.t()
        }

  @spec call(attrs) :: {:ok, Requisition.t()}
  def call(attrs) do
    attrs = Map.put(attrs, :reference, Ecto.UUID.generate())

    new()
    |> run(:nordigen_requisition, &create_nordigen_requisition/2, &delete_nordigen_requisition/3)
    |> run(:requisition, &create_requisition/2)
    |> transaction(Repo, attrs)
    |> then(fn
      {status, result, _} -> {status, result}
      result -> result
    end)
  end

  defp create_nordigen_requisition(_, attrs), do: Nordigen.create_requisition(attrs)

  defp delete_nordigen_requisition(%{"id" => id}, _, _) do
    case Nordigen.delete_requisition(id) do
      {:ok, _} -> :ok
    end
  end

  defp delete_nordigen_requisition(_, _, _), do: :ok

  defp create_requisition(%{nordigen_requisition: requisition}, %{user: user}) do
    status = Nordigen.map_requisition_status(requisition["status"])

    attrs = %{
      id: requisition["reference"],
      institution_id: requisition["institution_id"],
      nordigen_id: requisition["id"],
      status: status,
      link: requisition["link"],
      user_id: user.id
    }

    Institutions.create_requisition(attrs)
  end
end
