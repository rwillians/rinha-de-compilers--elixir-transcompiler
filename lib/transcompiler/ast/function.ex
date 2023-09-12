defmodule Transcompiler.AST.Function do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.Function{
          params: [Transcompiler.AST.Function.Parameter.t()],
          block: [Transcompiler.AST.Expr.t()],
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:params, :block, :location]
end
