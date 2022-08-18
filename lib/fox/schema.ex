defmodule Fox.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id

      require Ecto.Query
      import Fox.Repo, only: [schema_in_query?: 2]

      @behaviour Fox.Policy

      def restrict(_operation, query, opts)
          when Fox.Repo.schema_in_query?(query, __MODULE__) do
        if user_id = opts[:user_id] do
          {Ecto.Query.where(query, user_id: ^user_id), opts}
        else
          raise "expected user_id or skip_policy to be set"
        end
      end

      defoverridable Fox.Policy
    end
  end
end
