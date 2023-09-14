defmodule Transcompiler.If do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.If{
          condition: Transcompiler.Boolean.t() | Transcompiler.BinaryOp.t(),
          then: [Transcompiler.Expr.t(), ...],
          otherwise: [Transcompiler.Expr.t()],
          location: Transcompiler.Location.t()
        }
  defstruct [:condition, :then, :otherwise, :location]
end

defimpl Transpilable, for: Transcompiler.If do
  def to_elixir_ast(%{otherwise: nil} = ast, env) do
    {:if, [context: env, imports: [{1, Kernel}, {2, Kernel}]],
     [
       Transpilable.to_elixir_ast(ast.condition, env),
       [
         do: Transpilable.to_elixir_ast(ast.then, env),
         else: nil
       ]
     ]}
  end

  def to_elixir_ast(ast, env) do
    {:if, [context: env, imports: [{1, Kernel}, {2, Kernel}]],
     [
       Transpilable.to_elixir_ast(ast.condition, env),
       [
         do: Transpilable.to_elixir_ast(ast.then, env),
         else: Transpilable.to_elixir_ast(ast.otherwise, env)
       ]
     ]}
  end
end
