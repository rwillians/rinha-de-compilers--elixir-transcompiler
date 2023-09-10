defmodule Parser.Literal.Integer do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Literal.Integer{
          value: integer,
          location: Parser.Location.t()
        }
  defstruct [:value, :location]
end

defimpl Transpiler.Node, for: Parser.Literal.Integer do
  def transpile(node, _mod), do: node.value
end
