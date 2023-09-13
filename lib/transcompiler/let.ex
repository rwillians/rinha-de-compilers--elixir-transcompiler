defmodule Transcompiler.Let do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Let{
          var: Transcompiler.Parameter.t(),
          value: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:var, :value, location: nil]
end

defimpl Transcompiler.Transpiler, for: Transcompiler.Let do
  def to_elixir_ast(ast, env) do
    {:=, [], [
      {ast.var.name, [], env},
      Transcompiler.Transpiler.to_elixir_ast(ast.value, env)
    ]}
  end
end
