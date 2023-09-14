defmodule Transcompiler.Function do
  @moduledoc """
  Can be called recursivelly.
  """

  @typedoc false
  @type t :: %Transcompiler.Function{
          name: atom,
          params: [Transcompiler.Parameter.t()],
          block: [Transcompiler.Expr.t()],
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:name, :params, :block, location: nil]
end

defimpl Transpilable, for: Transcompiler.Function do
  def to_elixir_ast(ast, env) do
    params = Enum.map(ast.params, &Transpilable.to_elixir_ast(&1, env))
    block = Enum.map(ast.block, &Transpilable.to_elixir_ast(&1, env))

    {:def, [context: env, imports: [{1, Kernel}, {2, Kernel}]], [
      {ast.name, [context: env], params},
      [do: {:__block__, [], block}]
    ]}
  end
end
