defmodule Parser.Literal.Boolean do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Literal.Boolean{
          value: boolean,
          location: Parser.Location.t()
        }
  defstruct [:value, :location]
end
