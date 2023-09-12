defmodule Transcompiler.AST.Parameter do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.Parameter{
          name: atom,
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:name, :location]
end
