defmodule AST.Call do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Call{
          callee: fn_name :: atom,
          args: [AST.ast_term()],
          location: AST.Location.t()
        }
  defstruct [:callee, :args, :location]
end

defimpl Transpilable, for: AST.Call do
  import Enum, only: [map: 2]

  def to_elixir_ast(%{callee: %{name: :print}} = ast, env) do
    [arg] = map(ast.args, &Transpilable.to_elixir_ast(&1, env))

    print =
      {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [],
       [
         {:to_string, [context: env, imports: [{1, Kernel}]], [arg]}
       ]}

    {:__block__, [], [print, arg]}
  end

  def to_elixir_ast(%{callee: %{name: :first}} = ast, env) do
    args = map(ast.args, &Transpilable.to_elixir_ast(&1, env))

    {:elem,
     [
       context: Play,
       imports: [{2, Kernel}],
       file: ast.location.filename,
       line: ast.location.start.line
     ], args ++ [0]}
  end

  def to_elixir_ast(%{callee: %{name: :second}} = ast, env) do
    args = map(ast.args, &Transpilable.to_elixir_ast(&1, env))

    {:elem,
     [
       context: Play,
       imports: [{2, Kernel}],
       file: ast.location.filename,
       line: ast.location.start.line
     ], args ++ [1]}
  end

  def to_elixir_ast(ast, env) do
    args = map(ast.args, &Transpilable.to_elixir_ast(&1, env))

    {ast.callee.name, [context: env, file: ast.location.filename, line: ast.location.start.line],
     args}
  end
end
