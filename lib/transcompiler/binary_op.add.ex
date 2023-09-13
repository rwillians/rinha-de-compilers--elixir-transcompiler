defmodule Transcompiler.BinaryOp.Add do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.BinaryOp.Add{
          lhs: Transcompiler.Term.t(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:lhs, :rhs, location: nil]
end
