defmodule Transcompiler.AST.BinaryOp do
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
  @type t :: %Transcompiler.AST.BinaryOp{
          lhs: Transcompiler.AST.Term.t(),
          op: op(),
          rhs: Transcompiler.AST.Term.t(),
          location: Transcompiler.AST.Location.t()
        }
  defstruct [:lhs, :op, :rhs, :location]
end
