defmodule Transcompiler.Parameter do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Parameter{
          name: atom,
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:name, location: nil]
end

defimpl Transcompiler.Transpiler, for: Transcompiler.Parameter do
  def to_elixir_ast(ast, env), do: {ast.name, [], env}
end