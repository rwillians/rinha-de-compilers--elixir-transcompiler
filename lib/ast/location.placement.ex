defmodule AST.Location.Placement do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Location.Placement{
          offset: pos_integer,
          line: pos_integer,
          line_offset: pos_integer
        }
  defstruct [:offset, :line, :line_offset]
end
