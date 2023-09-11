defmodule Transpiler.Parser.Variable.Definition do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.Variable.Definition{
          name: Transpiler.Parser.Name.t(),
          value: Transpiler.Parser.expr(),
          location: Transpiler.Parser.Location.t(),
          next: Transpiler.Parser.expr()
        }
  defstruct [:name, :value, :location, next: nil]
end

defimpl Transpiler.Node, for: Transpiler.Parser.Variable.Definition do
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
