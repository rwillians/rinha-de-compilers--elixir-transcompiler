defmodule Transcompiler.AST.Boolean do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.Boolean{
          value: boolean,
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:value, :location]
end
