defmodule Transpiler.Parser.Module do
  @moduledoc """
  Represents the node that represents the AST for an entire file.
  """

  @typedoc false
  @type t :: %Transpiler.Parser.Module{
          name: String.t(),
          block: Transpiler.Parser.expr(),
          location: Transpiler.Parser.Location.t()
        }
  defstruct [:name, :block, :location]
end

defimpl Transpiler.Node, for: Transpiler.Parser.Module do
  def transpile(node, mod) do
    {:def, [context: mod, imports: [{1, Kernel}, {2, Kernel}]],
     [
       {:main, [context: mod], []},
       [
         do:
           {:__block__, [],
            List.flatten([
              Transpiler.Node.transpile(node.block, mod)
            ])}
       ]
     ]}
  end
end
