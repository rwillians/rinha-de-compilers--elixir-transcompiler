defmodule Parser.If do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.If{
          condition: Parser.expr(),
          then: Parser.expr(),
          otherwise: Parser.expr(),
          location: Parser.Location.t()
        }
  defstruct [:condition, :then, :otherwise, :location]
end

defimpl Transpiler.Node, for: Parser.If do
  def transpile(node, mod) do
    {:if, [context: mod, imports: [{2, Kernel}]],
     [
       Transpiler.Node.transpile(node.condition, mod),
       [
         do: Transpiler.Node.transpile(node.then, mod),
         else: Transpiler.Node.transpile(node.otherwise, mod)
       ]
     ]}
  end
end
