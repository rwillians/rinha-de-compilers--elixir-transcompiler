defmodule Transcompiler.Tuple do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Tuple{
          first: Transcompiler.Term.t(),
          second: Transcompiler.Term.t(),
          location: Transcompiler.Location.t()
        }
  defstruct [:first, :second, :location]
end

defimpl Transpilable, for: Transcompiler.Tuple do
  def to_elixir_ast(ast, env) do
    {
      Transpilable.to_elixir_ast(ast.first, env),
      Transpilable.to_elixir_ast(ast.second, env)
    }
  end
end
