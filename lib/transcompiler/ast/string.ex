defmodule Transcompiler.AST.String do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.String{
          value: String.t(),
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:value, :location]
end
