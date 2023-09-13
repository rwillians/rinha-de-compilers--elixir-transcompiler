defmodule Transcompiler.Tuple do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Tuple{
          first: Transcompiler.Term.t(),
          second: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:first, :second, location: nil]
end

defimpl Transcompiler.Transpiler, for: Transcompiler.Tuple do
  def to_elixir_ast(ast, env) do
    {
      Transcompiler.Transpiler.to_elixir_ast(ast.first, env),
      Transcompiler.Transpiler.to_elixir_ast(ast.second, env)
    }
  end
end
