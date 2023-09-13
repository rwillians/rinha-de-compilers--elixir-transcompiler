defmodule Transcompiler.BinaryOp do
  @moduledoc false

  @type op ::
          :add
          | :sub
          | :mul
          | :div
          | :rem
          | :eq
          | :neq
          | :lt
          | :gt
          | :lte
          | :gte
          | :and
          | :or

  @typedoc false
  @type t :: %Transcompiler.BinaryOp{
          lhs: Transcompiler.Term.t(),
          op: op(),
          rhs: Transcompiler.Term.t(),
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:lhs, :op, :rhs, location: nil]
end
