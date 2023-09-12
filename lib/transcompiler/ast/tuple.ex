defmodule Transcompiler.AST.Tuple do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.Tuple{
          first: Transcompiler.AST.Term.t(),
          second: Transcompiler.AST.Term.t(),
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:first, :second, :location]
end
