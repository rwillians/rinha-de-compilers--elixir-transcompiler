defmodule Parser.Function.Reference do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Function.Reference{
          name: String.t(),
          location: Parser.Location.t()
        }
  defstruct [:name, :location]
end
