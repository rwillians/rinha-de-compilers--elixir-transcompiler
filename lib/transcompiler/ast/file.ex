defmodule Transcompiler.AST.File do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.File{
          name: String.t(),
          block: [Transcompiler.AST.Expr.t()],
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:name, :block, :location]
end
