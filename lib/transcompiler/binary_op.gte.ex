defmodule Transcompiler.BinaryOp.Gte do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.BinaryOp.Gte{
          lhs: Transcompiler.Term.t(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:lhs, :rhs, location: nil]
end
