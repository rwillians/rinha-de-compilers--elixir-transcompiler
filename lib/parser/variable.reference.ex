defmodule Parser.Variable.Reference do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Variable.Reference{
          name: String.t(),
          location: Parser.Location.t()
        }
  defstruct [:name, :location]
end
