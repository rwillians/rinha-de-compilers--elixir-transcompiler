defmodule Parser.AST do
  @moduledoc false

  @typedoc false
  @type ast_expr ::
          AST.Let.t()
          | AST.If.t()
          | ast_term()

  @typedoc false
  @type ast_term ::
          AST.Integer.t()
          | AST.String.t()
          | AST.Call.t()
          | AST.BinaryOp.t()
          | AST.Boolean.t()
          | AST.Tuple.t()
          | AST.Lambda.t()
          | AST.Variable.t()
end
