defmodule Parser.If do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.If{
          condition: Parser.expr(),
          then: Parser.expr(),
          otherwise: Parser.expr(),
          location: Parser.Location.t()
        }
  defstruct [:condition, :then, :otherwise, :location]
end
