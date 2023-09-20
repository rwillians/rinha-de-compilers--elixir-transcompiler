defmodule AST.If do
  @moduledoc false

  @typedoc false
  @type t :: %AST.If{
          condition: AST.Boolean.t() | AST.BinaryOp.t(),
          then: [AST.ast_expr(), ...],
          otherwise: [AST.ast_expr()],
          location: AST.Location.t()
        }
  defstruct [:condition, :then, :otherwise, :location]
end

defimpl Transpilable, for: AST.If do
  def to_elixir_ast(%{otherwise: nil} = ast, env) do
    {:if,
     [
       context: env,
       imports: [{1, Kernel}, {2, Kernel}],
       file: ast.location.filename,
       line: ast.location.start.line
     ],
     [
       Transpilable.to_elixir_ast(ast.condition, env),
       [
         do: Transpilable.to_elixir_ast(ast.then, env),
         else: nil
       ]
     ]}
  end

  def to_elixir_ast(ast, env) do
    {:if,
     [
       context: env,
       imports: [{1, Kernel}, {2, Kernel}],
       file: ast.location.filename,
       line: ast.location.start.line
     ],
     [
       Transpilable.to_elixir_ast(ast.condition, env),
       [
         do: Transpilable.to_elixir_ast(ast.then, env),
         else: Transpilable.to_elixir_ast(ast.otherwise, env)
       ]
     ]}
  end
end
