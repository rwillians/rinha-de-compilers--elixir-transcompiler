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
  def to_elixir_ast(%{value: %Transcompiler.Lambda{}} = ast, env) do
    params = Enum.map(ast.value.params, &Transcompiler.Transpiler.to_elixir_ast(&1, env))
    block = Enum.map(ast.value.block, &Transcompiler.Transpiler.to_elixir_ast(&1, env))

    {:def, [context: env, imports: [{1, Kernel}, {2, Kernel}]], [
      {ast.var.name, [context: env], params},
      [do: block]
    ]}
  end

  def to_elixir_ast(ast, env) do
    {:=, [], [
      {ast.var.name, [], env},
      Transcompiler.Transpiler.to_elixir_ast(ast.value, env)
    ]}
  end
end
