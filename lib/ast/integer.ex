defmodule AST.Integer do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Integer{
          value: integer,
          location: AST.Location.t()
        }
  defstruct [:value, :location]
end

defimpl Transpilable, for: AST.Integer do
  def to_elixir_ast(ast, _env), do: ast.value
end
