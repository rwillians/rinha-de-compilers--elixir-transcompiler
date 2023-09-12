defmodule Transcompiler.AST.Location do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.AST.Location{
          filename: String.t(),
          start: pos_integer,
          end: pos_integer
        }
  defstruct [:filename, :start, :end]
end
