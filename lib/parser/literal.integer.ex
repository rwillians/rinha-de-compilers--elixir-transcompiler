defmodule Parser.Literal.Integer do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Literal.Integer{
          value: integer,
          location: Parser.Location.t()
        }
  defstruct [:value, :location]
end
