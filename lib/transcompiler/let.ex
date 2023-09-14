defmodule Transcompiler.Let do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Let{
          var: Transcompiler.Parameter.t(),
          value: Transcompiler.Term.t(),
          location: Transcompiler.Location.t()
        }
  defstruct [:var, :value, :location]
end

defimpl Transpilable, for: Transcompiler.Let do
  def to_elixir_ast(ast, env) do
    {:=, [], [
      {ast.var.name, [], env},
      Transpilable.to_elixir_ast(ast.value, env)
    ]}
  end
end
