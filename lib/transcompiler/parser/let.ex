defmodule Transcompiler.Parser.Let do
  @moduledoc false

  @type t :: %Transcompiler.Parser.Let{
          varname: atom,
          value: term
        }
  defstruct [:varname, :value]
end
