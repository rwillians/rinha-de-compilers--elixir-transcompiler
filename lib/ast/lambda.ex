defmodule AST.Lambda do
  @moduledoc """
  Can't do recursive calls.
  """

  @typedoc false
  @type t :: %AST.Lambda{
          params: [AST.Lambda.Parameter.t()],
          block: AST.Block.t(),
          location: AST.Location.t()
        }
  defstruct [:params, :block, :location]
end
