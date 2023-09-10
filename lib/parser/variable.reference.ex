defmodule Parser.Variable.Reference do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Variable.Reference{
          name: atom,
          location: Parser.Location.t()
        }
  defstruct [:name, :location]
end

defimpl Transpiler.Node, for: Parser.Variable.Reference do
  def transpile(node, mod), do: {node.name, [], mod}
end
