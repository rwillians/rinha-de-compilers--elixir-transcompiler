defmodule Parser.Function do
  @moduledoc false

  @typedoc false
  @type t :: %Parser.Function{
          name: Parser.Function.Name.t(),
          params: [Parser.Function.Parameter.t()],
          block: Parser.expr(),
          location: Parser.Location.t(),
          next: Parser.expr() | nil
        }
  defstruct [:name, :params, :block, :location, next: nil]
end
