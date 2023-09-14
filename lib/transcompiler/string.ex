defmodule Transcompiler.String do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.String{
          value: String.t(),
          location: Transcompiler.Location.t()
        }
  defstruct [:value, :location]
end

defimpl Transpilable, for: Transcompiler.String do
  def to_elixir_ast(ast, _), do: ast.value
end
