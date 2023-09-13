defmodule Transcompiler.BinaryOp.Lt do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.BinaryOp.Lt{
          lhs: Transcompiler.Term.t(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:lhs, :rhs, location: nil]
end
