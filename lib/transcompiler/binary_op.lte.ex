defmodule Transcompiler.BinaryOp.Lte do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.BinaryOp.Lte{
          lhs: Transcompiler.Term.t(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:lhs, :rhs, location: nil]
end

defimpl Transpilable, for: Transcompiler.BinaryOp.Lte do
  def to_elixir_ast(ast, env) do
    {:<=, [context: env, imports: [{2, Kernel}]], [
      Transpilable.to_elixir_ast(ast.lhs, env),
      Transpilable.to_elixir_ast(ast.rhs, env),
    ]}
  end
end
