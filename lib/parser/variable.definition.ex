defmodule Parser.Variable.Definition do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Variable.Definition{
          name: Parser.Name.t(),
          value: Parser.expr(),
          location: Parser.Location.t(),
          next: Parser.expr()
        }
  defstruct [:name, :value, :location, next: nil]
end

defimpl Transpiler.Node, for: Parser.Variable.Definition do
  def transpile(node, mod) do
    [
      {:=, [],
       [
         {node.name.text, [], mod},
         Transpiler.Node.transpile(node.value, mod)
       ]},
      if not is_nil(node.next) do
        Transpiler.Node.transpile(node.next, mod)
      end
    ]
    |> List.flatten()
    |> Enum.reject(&is_nil/1)
  end
end
