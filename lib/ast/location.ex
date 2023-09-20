defmodule AST.Location do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Location{
          filename: String.t(),
          start: AST.Location.Placement.t(),
          end: AST.Location.Placement.t()
        }
  defstruct [:filename, :start, :end]
end
