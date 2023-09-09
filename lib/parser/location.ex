defmodule Parser.Location do
  @moduledoc """
  Struct representing the location of a node.
  """

  @typedoc false
  @type t :: %Parser.Location{
          filename: String.t(),
          start: pos_integer,
          end: pos_integer
        }
  defstruct [:filename, :start, :end]
end
