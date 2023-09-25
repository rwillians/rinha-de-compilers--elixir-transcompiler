defmodule AST.Lambda do
  @moduledoc """
  Can't do recursive calls.
  """

  @typedoc false
  @type t :: %AST.Lambda{
          params: [AST.Parameter.t()],
          block: AST.Block.t(),
          location: AST.Location.t()
        }
  defstruct [:params, :block, :location]
end

defimpl Transpilable, for: AST.Lambda do
  def to_elixir_ast(ast, env) do
    params = Enum.map(ast.params, &Transpilable.to_elixir_ast(&1, env))

    {:fn, [],
     [
       {:->, [], [params, Transpilable.to_elixir_ast(ast.block, env)]}
     ]}
  end
end
