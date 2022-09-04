defmodule Fox.Institutions.Service.RefreshRequisitions do
  alias Fox.Institutions
  alias Fox.Institutions.Service.RefreshRequisition
  alias Fox.Repo

  def call do
    Institutions.list_requisitions()
    |> Enum.map(&RefreshRequisition.call/1)
    |> Repo.summarize_results()
  end
end
