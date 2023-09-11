defmodule Transpiler.Parser.Function.Call do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.Function.Call{
          callee: Transpiler.Parser.Function.Reference.t(),
          args: [Transpiler.Parser.expr()],
          location: Transpiler.Parser.Location.t(),
          next: Transpiler.Parser.expr() | nil
        }
  defstruct [:callee, :args, :location, next: nil]
end

defimpl Transpiler.Node, for: Transpiler.Parser.Function.Call do
  def transpile(node, mod) do
    args =
      for arg <- node.args,
          do: Transpiler.Node.transpile(arg, mod)

    {node.callee.name, [], args}
  end
end
