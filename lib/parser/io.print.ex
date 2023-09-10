defmodule Parser.IO.Print do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.IO.Print{
          value: Parser.expr(),
          location: Parser.Location.t()
        }
  defstruct [:value, :location]
end

defimpl Transpiler.Node, for: Parser.IO.Print do
  def transpile(node, mod) do
    {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [],
     [
       {{:., [], [{:__aliases__, [alias: false], [:Kernel]}, :to_string]}, [],
        [
          Transpiler.Node.transpile(node.value, mod)
        ]}
     ]}
  end
end
