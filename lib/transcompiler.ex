defmodule Transcompiler do
  @moduledoc """
  A Source-to-Source Transcompiler from `rinha` language to `Elixir`.
  """

  @doc false
  defmacro __using__(opts) do
    {:file, path: <<_, _::binary>> = path} = Keyword.fetch!(opts, :source)
    parser = Keyword.fetch!(opts, :parser) |> Macro.expand(__CALLER__)

    quote do
      @external_resource unquote(path)

      ast = File.read!(unquote(path))
            |> unquote(parser).parse(unquote(path))
            |> Ex.Tuple.unwrap!()
            |> unquote(__MODULE__).transpile(__MODULE__)

      Module.eval_quoted(__MODULE__, ast)
    end
  end

  @doc """
  Transpiles the given AST into Elixir AST.
  """
  @spec transpile(Transcompiler.AST.Expr.t(), env :: module) :: Macro.t()

  def transpile(%Transcompiler.File{} = ast, env),
    do: Transcompiler.Transpiler.to_elixir_ast(ast, env)
end
