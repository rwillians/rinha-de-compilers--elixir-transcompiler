defmodule Parser.Function.Call do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Function.Call{
          callee: Parser.Function.Reference.t(),
          args: [Parser.expr()],
          location: Parser.Location.t(),
          next: Parser.expr() | nil
        }
  defstruct [:callee, :args, :location, next: nil]
end

defimpl Transpiler.Node, for: Parser.Function.Call do
  def transpile(node, mod) do
    args =
      for arg <- node.args,
          do: Transpiler.Node.transpile(arg, mod)

    {node.callee.name, [], args}
  end
end
