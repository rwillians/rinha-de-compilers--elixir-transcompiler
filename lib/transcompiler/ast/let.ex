defmodule Transcompiler.AST.Let do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.Let{
          var: Transcompiler.AST.Parameter.t(),
          value: Transcompiler.AST.Term.t(),
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:var, :value, :location]
end
