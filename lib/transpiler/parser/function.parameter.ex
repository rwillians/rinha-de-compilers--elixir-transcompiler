defmodule Transpiler.Parser.Function.Parameter do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.Function.Parameter{
          name: atom,
          location: Transpiler.Parser.Location.t()
        }
  defstruct [:name, :location]
end

defimpl Transpiler.Node, for: Transpiler.Parser.Function.Parameter do
  def transpile(node, mod), do: {node.name, [], mod}
end
