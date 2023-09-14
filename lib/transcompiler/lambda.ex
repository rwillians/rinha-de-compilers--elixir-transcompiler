defmodule Transcompiler.Lambda do
  @moduledoc """
  Can't do recursive calls.
  """

  @typedoc false
  @type t :: %Transcompiler.Lambda{
          params: [Transcompiler.Lambda.Parameter.t()],
          block: Transcompiler.Block.t(),
          location: Transcompiler.Location.t()
        }
  defstruct [:params, :block, :location]
end
