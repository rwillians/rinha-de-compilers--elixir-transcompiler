defmodule Transcompiler.AST.Expr do
  @moduledoc false

  @typedoc false
  @type t ::
          Transcompiler.AST.Let.t()
          | Transcompiler.AST.Function.t()
          | Transcompiler.AST.If.t()
          | Transcompiler.AST.Term.t()
end
