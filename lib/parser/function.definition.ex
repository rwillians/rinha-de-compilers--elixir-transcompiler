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
