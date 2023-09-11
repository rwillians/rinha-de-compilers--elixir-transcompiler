defmodule Transpiler.Parser.Literal.Integer do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.Literal.Integer{
          value: integer,
          location: Transpiler.Parser.Location.t()
        }
  defstruct [:value, :location]
end

defimpl Transpiler.Node, for: Transpiler.Parser.Literal.Integer do
  def transpile(node, _mod), do: node.value
end
