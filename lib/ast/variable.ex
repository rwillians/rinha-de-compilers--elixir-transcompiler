defmodule AST.Variable do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Variable{
          name: atom,
          location: AST.Location.t()
        }
  defstruct [:name, :location]
end

defimpl Transpilable, for: AST.Variable do
  def to_elixir_ast(ast, env),
    do: {ast.name, [file: ast.location.filename, line: ast.location.start.line], env}
end
