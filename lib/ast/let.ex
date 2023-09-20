defmodule AST.Let do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Let{
          var: AST.Parameter.t(),
          value: AST.ast_term(),
          location: AST.Location.t()
        }
  defstruct [:var, :value, :location]
end

defimpl Transpilable, for: AST.Let do
  import Enum, only: [map: 2]

  # Transpile `let x = lambda` as a module function so that recursion is allowed.
  # As a module public function, it can be called from other modules -- that's
  # what allows me to write doctests for `.rinha` programs.
  def to_elixir_ast(%{value: %AST.Lambda{}} = ast, env) do
    params = map(ast.value.params, &Transpilable.to_elixir_ast(&1, env))

    {:def,
     [
       context: env,
       imports: [{1, Kernel}, {2, Kernel}],
       file: ast.location.filename,
       line: ast.location.start.line
     ],
     [
       {ast.var.name, [context: env], params},
       [do: Transpilable.to_elixir_ast(ast.value.block, env)]
     ]}
  end

  def to_elixir_ast(ast, env) do
    {:=, [file: ast.location.filename, line: ast.location.start.line],
     [
       {ast.var.name, [], env},
       Transpilable.to_elixir_ast(ast.value, env)
     ]}
  end
end
