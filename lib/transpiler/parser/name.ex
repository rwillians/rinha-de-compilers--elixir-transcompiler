defmodule Transpiler.Parser.Name do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.Name{
          text: atom,
          location: Transpiler.Parser.Location.t()
        }
  defstruct [:text, :location]
end
