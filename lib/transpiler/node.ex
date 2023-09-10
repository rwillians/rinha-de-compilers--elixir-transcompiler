defprotocol Transpiler.Node do
  @moduledoc false

  @doc """
  A function capable of producing AST representing the given node `t`.
  """
  @spec transpile(t, module) :: Macro.t()

  def transpile(t, mod)
end
