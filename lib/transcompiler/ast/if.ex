defmodule Transcompiler.AST.If do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.If{
          condition: Transcompiler.AST.Boolean.t() | Transcompiler.AST.BinaryOp.t(),
          then: [Transcompiler.AST.Expr.t(), ...],
          otherwise: [Transcompiler.AST.Expr.t()],
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:condition, :then, :otherwise, :location]
end
