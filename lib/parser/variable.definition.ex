defmodule Parser.Variable.Definition do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Variable.Definition{
          name: atom,
          value: Parser.expr(),
          location: Parser.Location.t(),
          next: Parser.expr()
        }
  defstruct [:name, :value, :location, next: nil]
end
