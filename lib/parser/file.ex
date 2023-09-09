defmodule Parser.File do
  @moduledoc """
  Represents the node that represents the AST for an entire file.
  """

  @typedoc false
  @type t :: %Parser.File{
          name: String.t(),
          expr: struct,
          location: Parser.Location.t()
        }
  defstruct [:name, :expr, :location]
end
