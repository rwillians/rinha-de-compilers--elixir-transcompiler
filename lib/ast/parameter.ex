defmodule AST.Parameter do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Parameter{
          name: atom,
          location: AST.Location.t()
        }
  defstruct [:name, :location]
end

defimpl Transpilable, for: AST.Parameter do
  def to_elixir_ast(ast, env),
    do: {ast.name, [file: ast.location.filename, line: ast.location.start.line], env}
end
