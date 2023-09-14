defmodule Transcompiler.BinaryOp.Gte do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.BinaryOp.Gte{
          lhs: Transcompiler.Term.t(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:lhs, :rhs, location: nil]
end

defimpl Transpilable, for: Transcompiler.BinaryOp.Gte do
  def to_elixir_ast(ast, env) do
    {:>=, [context: env, imports: [{2, Kernel}]], [
      Transpilable.to_elixir_ast(ast.lhs, env),
      Transpilable.to_elixir_ast(ast.rhs, env),
    ]}
  end
end
