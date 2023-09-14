defmodule Transcompiler do
  @moduledoc """
  A Source-to-Source Transcompiler from `rinha` language to `Elixir`.

  ## Examples

  ### File as source:

      defmodule Rinha.Fib do
        use Transcompiler,
          source: {:file, path: ".rinha/files/fib.rinha"},
          parser: Rinha.Parser
      end

  ### Inline source:

      defmodule Rinha.Math do
        use Transcompiler,
          parser: Rinha.Parser,
          source: \"\"\"
          let add = fn (a, b) => { a + b };
          \"\"\"
      end

  """

  @doc false
  defmacro __using__([{_, _}, {_, _}] = opts) do
    parser = Keyword.fetch!(opts, :parser) |> Macro.expand(__CALLER__)

    {source, path} =
      case Keyword.fetch!(opts, :source) do
        {:file, path: <<_, _::binary>> = path} -> {File.read!(path), path}
        <<_, _::binary>> = source -> {source, "::in-line"}
      end

    quote do
      @external_resource unquote(path)

      ast = unquote(source)
            |> unquote(parser).parse(unquote(path))
            |> Ex.Tuple.unwrap!()
            |> unquote(__MODULE__).transpile(__MODULE__)

      Module.eval_quoted(__MODULE__, ast)
    end
  end

  @doc """
  Transpiles a given generic AST node into Elixir AST.
  """
  @spec transpile(Transcompiler.AST.Expr.t(), env :: module) :: Macro.t()

  def transpile(expr, env),
    do: Transpilable.to_elixir_ast(expr, env)
end
