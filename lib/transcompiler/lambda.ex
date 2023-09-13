defmodule Transcompiler.Lambda do
  @moduledoc """
  Can't do recursive calls.
  """

  @typedoc false
  @type t :: %Transcompiler.Lambda{
          params: [Transcompiler.Lambda.Parameter.t()],
          block: [Transcompiler.Expr.t()],
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:params, :block, location: nil]
end

defimpl Transcompiler.Transpiler, for: Transcompiler.Lambda do
  def to_elixir_ast(ast, _env), do: ast.value
end
