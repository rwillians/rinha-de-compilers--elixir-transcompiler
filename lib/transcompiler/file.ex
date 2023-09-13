defmodule Transcompiler.File do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.File{
          name: String.t(),
          block: [Transcompiler.Expr.t()],
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:name, :block, location: nil]
end

defimpl Transcompiler.Transpiler, for: Transcompiler.File do
  def to_elixir_ast(ast, env) do
    []
  end
end
