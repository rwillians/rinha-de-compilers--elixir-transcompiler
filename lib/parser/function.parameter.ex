defmodule Parser.Function.Parameter do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Function.Parameter{
          name: atom,
          location: Parser.Location.t()
        }
  defstruct [:name, :location]
end

defimpl Transpiler.Node, for: Parser.Function.Parameter do
  def transpile(node, mod), do: {node.name, [], mod}
end
