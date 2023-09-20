defmodule AST.File do
  @moduledoc false

  @typedoc false
  @type t :: %AST.File{
          name: String.t(),
          block: [AST.ast_expr()],
          location: AST.Location.t()
        }
  defstruct [:name, :block, :location]
end

defimpl Transpilable, for: AST.File do
  import Enum, only: [filter: 2, map: 2, reject: 2]

  def to_elixir_ast(ast, env) do
    fns = filter(ast.block, &match?(%AST.Let{value: %AST.Lambda{}}, &1))
    exprs = reject(ast.block, &match?(%AST.Let{value: %AST.Lambda{}}, &1))

    # KNOWN ISSUE:  if a function is defined elsewhere in the file, for example
    #               inside another function or inside an `if`, then it won't get
    #               created as a module function. Instead, they will get created
    #               as a lambda alocated to a variable, limited to its scope
    #               (expected behavior) and NOT allowed to do recursions
    #               (unexpected behaviour).

    block =
      map(fns, &Transpilable.to_elixir_ast(&1, env)) ++
        [
          {:def, [context: env, imports: [{1, Kernel}, {2, Kernel}]],
           [
             {:main, [context: env, file: ast.location.filename, line: ast.location.start.line],
              []},
             [
               do: {:__block__, [], map(exprs, &Transpilable.to_elixir_ast(&1, env))}
             ]
           ]}
        ]

    {:__block__, [], block}
  end
end
