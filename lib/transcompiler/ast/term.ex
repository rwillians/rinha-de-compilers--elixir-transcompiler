defmodule Transcompiler.AST.Term do
  @moduledoc false

  @type t ::
    Transcompiler.AST.Integer.t()
    | Transcompiler.AST.String.t()
    | Transcompiler.AST.Function.Call.t()
    | Transcompiler.AST.BinaryOp.t()
    | Transcompiler.AST.Boolean.t()
    | Transcompiler.AST.Tuple.t()
    | Transcompiler.AST.Variable.Name.t()
end
