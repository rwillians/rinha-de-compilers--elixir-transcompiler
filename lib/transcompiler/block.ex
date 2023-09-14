defmodule Transcompiler.Block do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Block{
          exprs: [Transcompiler.Expr.t()],
          location: Transcompiler.Location.t()
        }
  defstruct [:exprs, :location]
end

defimpl Transpilable, for: Transcompiler.Block do
  def to_elixir_ast(ast, env) do
    {:__block__, [], Enum.map(ast.exprs, &Transpilable.to_elixir_ast(&1, env))}
  end
end
