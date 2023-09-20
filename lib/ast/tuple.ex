defmodule AST.Tuple do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Tuple{
          first: AST.ast_term(),
          second: AST.ast_term(),
          location: AST.Location.t()
        }
  defstruct [:first, :second, :location]
end

defimpl Transpilable, for: AST.Tuple do
  def to_elixir_ast(ast, env) do
    {:{}, [file: ast.location.filename, line: ast.location.start.line],
     [
       Transpilable.to_elixir_ast(ast.first, env),
       Transpilable.to_elixir_ast(ast.second, env)
     ]}
  end
end
