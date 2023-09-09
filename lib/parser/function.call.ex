defmodule Parser.Function.Call do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Function.Call{
          callee: Parser.Function.Reference.t(),
          args: [Parser.expr()],
          location: Parser.Location.t()
        }
  defstruct [:callee, :args, :location]
end
