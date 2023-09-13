defmodule Transcompiler.If do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.If{
          condition: Transcompiler.Boolean.t() | Transcompiler.BinaryOp.t(),
          then: [Transcompiler.Expr.t(), ...],
          otherwise: [Transcompiler.Expr.t()],
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:condition, :then, :otherwise, location: nil]
end

defimpl Transcompiler.Transpiler, for: Transcompiler.If do
  def to_elixir_ast(%{otherwise: nil} = ast, env) do
    {:if, [context: env, imports: [{1, Kernel}, {2, Kernel}]],
     [
       Transcompiler.Transpiler.to_elixir_ast(ast.condition, env),
       [do: Transcompiler.Transpiler.to_elixir_ast(ast.then, env)]
     ]}
  end

  def to_elixir_ast(ast, env) do
    {:if, [context: env, imports: [{1, Kernel}, {2, Kernel}]],
     [
       Transcompiler.Transpiler.to_elixir_ast(ast.condition, env),
       [
         do: Transcompiler.Transpiler.to_elixir_ast(ast.then, env),
         else: Transcompiler.Transpiler.to_elixir_ast(ast.otherwise, env)
       ]
     ]}
  end
end
