defmodule Transcompiler.Function do
  @moduledoc """
  Can be called recursivelly.
  """

  @typedoc false
  @type t :: %Transcompiler.Function{
          name: Transcompiler.Parameter.t(),
          params: [Transcompiler.Parameter.t()],
          block: [Transcompiler.Expr.t()],
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:name, :params, :block, location: nil]
end

defimpl Transcompiler.Transpiler, for: Transcompiler.Function do
  def to_elixir_ast(ast, env) do
    []
  end
end
