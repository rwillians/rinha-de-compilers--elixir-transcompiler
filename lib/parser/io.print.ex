defmodule Parser.IO.Print do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.IO.Print{
          value: Parser.expr(),
          location: Parser.Location.t()
        }
  defstruct [:value, :location]
end
