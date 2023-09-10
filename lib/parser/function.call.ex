defmodule Parser.Function.Call do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Function.Call{
          callee: Parser.Function.Reference.t(),
          args: [Parser.expr()],
          location: Parser.Location.t(),
          next: Parser.expr() | nil
        }
  defstruct [:callee, :args, :location, next: nil]
end
