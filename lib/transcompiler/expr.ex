defmodule Transcompiler.Expr do
  @moduledoc false

  @typedoc false
  @type t ::
          Transcompiler.Let.t()
          | Transcompiler.Lambda.t()
          | Transcompiler.If.t()
          | Transcompiler.Term.t()
end
