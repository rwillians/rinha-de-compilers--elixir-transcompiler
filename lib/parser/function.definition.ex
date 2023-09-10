defmodule Parser.Function.Definition do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Function.Definition{
          name: Parser.Name.t(),
          params: [Parser.Function.Parameter.t()],
          block: Parser.node(),
          location: Parser.Location.t(),
          next: Parser.node() | nil
        }
  defstruct [:name, :params, :block, :location, next: nil]
end

defimpl Transpiler.Node, for: Parser.Function.Definition do
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
