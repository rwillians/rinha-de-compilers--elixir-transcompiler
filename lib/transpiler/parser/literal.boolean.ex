defmodule Transpiler.Parser.Literal.Boolean do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.Literal.Boolean{
          value: boolean,
          location: Transpiler.Parser.Location.t()
        }
  defstruct [:value, :location]
end
