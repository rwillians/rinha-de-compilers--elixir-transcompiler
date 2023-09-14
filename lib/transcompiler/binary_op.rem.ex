defmodule Transcompiler.BinaryOp.Rem do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.BinaryOp.Rem{
          lhs: Transcompiler.Term.t(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:lhs, :rhs, location: nil]
end

defimpl Transpilable, for: Transcompiler.BinaryOp.Rem do
  def to_elixir_ast(ast, env) do
    {:rem, [context: env, imports: [{2, Kernel}]],
     [
       Transpilable.to_elixir_ast(ast.lhs, env),
       Transpilable.to_elixir_ast(ast.rhs, env)
     ]}
  end
end
