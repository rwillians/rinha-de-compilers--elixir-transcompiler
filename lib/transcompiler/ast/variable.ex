defmodule Transcompiler.AST.Variable do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.Variable{
          name: atom,
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:name, :location]
end
