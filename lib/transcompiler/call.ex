defmodule Transcompiler.Call do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Call{
          callee: fn_name :: atom,
          args: [Transcompiler.Term.t()],
          location: Transcompiler.Location.t() | nil
        }
  defstruct [:callee, :args, location: nil]
end
