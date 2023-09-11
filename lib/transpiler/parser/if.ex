defmodule Transpiler.Parser.If do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.If{
          condition: Transpiler.Parser.expr(),
          then: Transpiler.Parser.expr(),
          otherwise: Transpiler.Parser.expr(),
          location: Transpiler.Parser.Location.t()
        }
  defstruct [:condition, :then, :otherwise, :location]
end

defimpl Transpiler.Node, for: Transpiler.Parser.If do
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
