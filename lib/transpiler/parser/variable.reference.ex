defmodule Transpiler.Parser.Variable.Reference do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.Variable.Reference{
          name: atom,
          location: Transpiler.Parser.Location.t()
        }
  defstruct [:name, :location]
end

defimpl Transpiler.Node, for: Transpiler.Parser.Variable.Reference do
  def transpile(node, mod), do: {node.name, [], mod}
end
