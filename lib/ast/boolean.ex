defmodule AST.Boolean do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Boolean{
          value: boolean,
          location: AST.Location.t()
        }
  defstruct [:value, :location]
end

defimpl Transpilable, for: AST.Boolean do
  def to_elixir_ast(ast, _), do: ast.value
end
