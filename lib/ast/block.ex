defmodule AST.Block do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Block{
          exprs: [AST.ast_expr()],
          location: AST.Location.t()
        }
  defstruct [:exprs, :location]
end

defimpl Transpilable, for: AST.Block do
  import Enum, only: [map: 2]

  def to_elixir_ast(ast, env) do
    {:__block__, [file: ast.location.filename, line: ast.location.start.line],
     map(ast.exprs, &Transpilable.to_elixir_ast(&1, env))}
  end
end
