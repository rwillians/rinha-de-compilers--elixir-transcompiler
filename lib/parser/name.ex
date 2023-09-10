defmodule Parser.Name do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Name{
          text: atom,
          location: Parser.Location.t()
        }
  defstruct [:text, :location]
end
