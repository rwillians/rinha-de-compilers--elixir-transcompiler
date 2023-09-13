defmodule Transcompiler.Term do
  @moduledoc false

  @type t ::
    Transcompiler.Integer.t()
    | Transcompiler.String.t()
    | Transcompiler.Call.t()
    | Transcompiler.BinaryOp.t()
    | Transcompiler.Boolean.t()
    | Transcompiler.Tuple.t()
    | Transcompiler.Variable.Name.t()
end
