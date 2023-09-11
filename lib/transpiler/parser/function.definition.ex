defmodule Transpiler.Parser.Function.Definition do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.Function.Definition{
          name: Transpiler.Parser.Name.t(),
          params: [Transpiler.Parser.Function.Parameter.t()],
          block: Transpiler.Parser.node(),
          location: Transpiler.Parser.Location.t(),
          next: Transpiler.Parser.node() | nil
        }
  defstruct [:name, :params, :block, :location, next: nil]
end

defimpl Transpiler.Node, for: Transpiler.Parser.Function.Definition do
  def transpile(node, mod) do
    params =
      for p <- node.params,
          do: Transpiler.Node.transpile(p, mod)

    {:def, [context: mod, imports: [{1, Kernel}, {2, Kernel}]],
      [
        {node.name.text, [context: mod], params},
        [
          do: {:__block__, [], List.flatten([Transpiler.Node.transpile(node.block, mod)])}
        ]
      ]}
  end
end
