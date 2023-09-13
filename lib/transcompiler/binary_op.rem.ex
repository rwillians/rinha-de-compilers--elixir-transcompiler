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

defimpl Transcompiler.Transpiler, for: Transcompiler.BinaryOp.Rem do
  def to_elixir_ast(ast, env) do
    {:rem, [context: env, imports: [{2, Kernel}]],
     [
       Transcompiler.Transpiler.to_elixir_ast(ast.lhs, env),
       Transcompiler.Transpiler.to_elixir_ast(ast.rhs, env)
     ]}
  end
end
