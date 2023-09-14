defmodule Transcompiler.Boolean do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Boolean{
          value: boolean,
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:value, location: nil]
end

defimpl Transpilable, for: Transcompiler.Boolean do
  def to_elixir_ast(ast, _), do: ast.value
end
