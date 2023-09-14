defmodule Transcompiler.Function do
  @moduledoc """
  Can be called recursivelly.
  """

  @typedoc false
  @type t :: %Transcompiler.Function{
          var: Transcompiler.Variable.t(),
          params: [Transcompiler.Parameter.t()],
          block: Transcompiler.Block.t(),
          location: Transcompiler.Location.t()
        }
  defstruct [:var, :params, :block, :location]
end

defimpl Transpilable, for: Transcompiler.Function do
  def to_elixir_ast(ast, env) do
    params = Enum.map(ast.params, &Transpilable.to_elixir_ast(&1, env))

    {:def, [context: env, imports: [{1, Kernel}, {2, Kernel}]], [
      {ast.var.name, [context: env], params},
      [do: Transpilable.to_elixir_ast(ast.block, env)]
    ]}
  end
end
