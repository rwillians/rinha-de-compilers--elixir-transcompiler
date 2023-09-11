defmodule Transpiler.Parser.IO.Print do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.IO.Print{
          value: Transpiler.Parser.expr(),
          location: Transpiler.Parser.Location.t()
        }
  defstruct [:value, :location]
end

defimpl Transpiler.Node, for: Transpiler.Parser.IO.Print do
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
