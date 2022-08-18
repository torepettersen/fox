defmodule Fox.Policy do
  alias Ecto.Query

  @callback restrict(operation, query :: Query.t(), opts :: Keyword.t()) ::
              {Query.t(), Keyword.t()}
            when operation: :all | :update_all | :delete_all | :stream | :insert_all
end
