defmodule Transpiler.Parser.Function.Reference do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.Function.Reference{
          name: atom,
          location: Transpiler.Parser.Location.t()
        }
  defstruct [:name, :location]
end
