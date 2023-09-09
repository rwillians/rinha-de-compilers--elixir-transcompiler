defmodule Parser.Function.Parameter do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Function.Parameter{
          name: String.t(),
          location: Parser.Location.t()
        }
  defstruct [:name, :location]
end
