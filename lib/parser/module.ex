defmodule Parser.Module do
  @moduledoc """
  Represents the node that represents the AST for an entire file.
  """

  @typedoc false
  @type t :: %Parser.Module{
          name: String.t(),
          block: Parser.expr(),
          location: Parser.Location.t()
        }
  defstruct [:name, :block, :location]
end
