defmodule Parser.Function.Reference do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Function.Reference{
          name: atom,
          location: Parser.Location.t()
        }
  defstruct [:name, :location]
end
