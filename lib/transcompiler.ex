defmodule Transcompiler do
  @moduledoc """
  A Source-to-Source Transcompiler from `rinha` language to `Elixir`.

  ## Examples

  ### File as source:

      defmodule Rinha.Fib do
        use Transcompiler,
          source: {:file, path: ".rinha/files/fib.rinha"},
          parser: Parser
      end

  ### Inline source:

      defmodule Rinha.Math do
        use Transcompiler,
          parser: Parser,
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

      result = unquote(parser).parse(unquote(source), unquote(path))

      ast =
        case result do
          {:ok, expr} ->
            Transpilable.to_elixir_ast(expr, __MODULE__)

          {:error, msg, file, line} ->
            raise CompileError,
              file: file,
              line: line,
              description: msg
        end

      Module.eval_quoted(__MODULE__, ast)
    end
  end
end
