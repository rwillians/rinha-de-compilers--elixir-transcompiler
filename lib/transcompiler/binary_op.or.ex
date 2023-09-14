defmodule Transcompiler.BinaryOp.Or do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.BinaryOp.Or{
          lhs: Transcompiler.Term.t(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t()
        }
  defstruct [:lhs, :rhs, :location]
end

defimpl Transpilable, for: Transcompiler.BinaryOp.Or do
  def to_elixir_ast(ast, env) do
    {:or, [context: env, imports: [{2, Kernel}]], [
      Transpilable.to_elixir_ast(ast.lhs, env),
      Transpilable.to_elixir_ast(ast.rhs, env),
    ]}
  end
end
