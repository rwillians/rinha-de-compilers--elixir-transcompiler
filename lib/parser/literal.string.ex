defmodule Parser.Literal.String do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Literal.String{
          value: String.t(),
          location: Parser.Location.t()
        }
  defstruct [:value, :location]
end
