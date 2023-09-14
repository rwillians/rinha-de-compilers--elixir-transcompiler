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

defimpl Transpilable, for: Transcompiler.If do
  def to_elixir_ast(%{otherwise: nil} = ast, env) do
    then = Enum.map(ast.then, &Transpilable.to_elixir_ast(&1, env))

    {:if, [context: env, imports: [{1, Kernel}, {2, Kernel}]],
     [
       Transpilable.to_elixir_ast(ast.condition, env),
       [do: {:__block__, [], then}]
     ]}
  end

  def to_elixir_ast(ast, env) do
    then = Enum.map(ast.then, &Transpilable.to_elixir_ast(&1, env))
    otherwise = Enum.map(ast.otherwise, &Transpilable.to_elixir_ast(&1, env))

    {:if, [context: env, imports: [{1, Kernel}, {2, Kernel}]],
     [
       Transpilable.to_elixir_ast(ast.condition, env),
       [
         do: {:__block__, [], then},
         else: {:__block__, [], otherwise}
       ]
     ]}
  end
end
