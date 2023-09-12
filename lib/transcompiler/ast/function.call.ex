defmodule Transcompiler.AST.Function.Call do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.Function.Call{
          callee: atom,
          args: [Transcompiler.AST.Term.t()],
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:callee, :args, :location]
end
