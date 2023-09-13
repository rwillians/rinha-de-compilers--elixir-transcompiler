defprotocol Transcompiler.Transpiler do
  @moduledoc false

  @doc false
  @spec to_elixir_ast(ast :: struct, env :: module) :: Macro.t()

  def to_elixir_ast(ast, env)
end
