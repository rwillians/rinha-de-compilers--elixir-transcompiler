defmodule Transcompiler.BinaryOp.Gt do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.BinaryOp.Gt{
          lhs: Transcompiler.Term.t(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:lhs, :rhs, location: nil]
end
