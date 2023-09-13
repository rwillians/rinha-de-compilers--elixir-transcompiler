defmodule Transcompiler.BinaryOp.And do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.BinaryOp.And{
          lhs: Transcompiler.Term.t(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:lhs, :rhs, location: nil]
end
