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

defimpl Transpilable, for: Transcompiler.File do
  def to_elixir_ast(ast, env) do
    fns = Enum.filter(ast.block, &(&1.__struct__ == Transcompiler.Function))
    tokens = Enum.reject(ast.block, &(&1.__struct__ == Transcompiler.Function))

    # KNOWN ISSUE / TODO:   if a function is defined elsewhere in the file, for
    #                       example inside another function or inside an `if`,
    #                       then they won't get created -- will likely cause a
    #                       compile error or worst, a runtime error.


    block =
      Enum.map(fns, &Transpilable.to_elixir_ast(&1, env)) ++
        [
          {:def, [context: env, imports: [{1, Kernel}, {2, Kernel}]],
           [
             {:main, [context: env], []},
             [
               do: {:__block__, [], Enum.map(tokens, &Transpilable.to_elixir_ast(&1, env))}
             ]
           ]}
        ]

    {:__block__, [], block}
  end
end
