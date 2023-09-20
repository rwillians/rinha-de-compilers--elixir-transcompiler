defmodule AST.String do
  @moduledoc false

  @typedoc false
  @type t :: %AST.String{
          value: String.t(),
          location: AST.Location.t()
        }
  defstruct [:value, :location]
end

defimpl Transpilable, for: AST.String do
  def to_elixir_ast(ast, _), do: ast.value
end
