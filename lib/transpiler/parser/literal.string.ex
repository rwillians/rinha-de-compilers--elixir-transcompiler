defmodule Transpiler.Parser.Literal.String do
  @moduledoc false

  @typedoc false
  @type t :: %Transpiler.Parser.Literal.String{
          value: String.t(),
          location: Transpiler.Parser.Location.t()
        }
  defstruct [:value, :location]
end
