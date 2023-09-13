defmodule Transcompiler.Location do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Location{
          filename: String.t(),
          start: pos_integer,
          end: pos_integer
        }
  defstruct [:filename, :start, :end]
end
