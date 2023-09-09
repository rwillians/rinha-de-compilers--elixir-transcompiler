defmodule Parser.BinaryOp do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.BinaryOp{
          lhs: Parser.expr(),
          op: :eq | :ne | :lt | :gt | :lte | :gte | :add | :sub | :mult | :div,
          rhs: Parser.expr(),
          location: Parser.Location.t()
        }
  defstruct [:lhs, :op, :rhs, :location]
end
