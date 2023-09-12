defmodule Transcompiler.AST.Integer do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.Integer{
          value: integer,
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:value, :location]
end
