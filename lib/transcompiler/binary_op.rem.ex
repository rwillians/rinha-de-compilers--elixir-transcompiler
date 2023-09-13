defmodule Transcompiler.BinaryOp.Rem do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.BinaryOp.Rem{
          lhs: Transcompiler.Term.t(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:lhs, :rhs, location: nil]
end
