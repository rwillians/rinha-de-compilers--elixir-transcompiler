defmodule Transcompiler.Integer do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Integer{
          value: integer,
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:value, location: nil]
end

defimpl Transcompiler.Transpiler, for: Transcompiler.Integer do
  def to_elixir_ast(ast, _env), do: ast.value
end
