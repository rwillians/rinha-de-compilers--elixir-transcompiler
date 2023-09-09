defmodule Parser.Function.Name do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Function.Name{
          text: String.t(),
          location: Parser.Location.t()
        }
  defstruct [:text, :location]
end
