defmodule Transpiler do
  @moduledoc """
  Use this when you want your module to be built from transpiling some code.

  The transpiler takes a parse tree made of `Parser.*` modules and transpile
  then to Elixir AST at compile time. That means no interpretation or
  transpiling during runtime. The performance should be the same as if the
  code were written in Elixir.

  ## Options

  You MUST specify 2 options when using `Transpiler`:
  - `source`: specifies what is your source and, depending on the type of
    source, you also no to specify where the source can be loaded from;
  - `parser`: A módule with the functions `parser/2` and `parse_many/2` (see
    `Rinha.Parser` for an example).

  ### Types of `source`

  These are the types os source that are supported:
  - `:ast`: it specifies that our source is a generic ast, it can be used as
    follows 👇

    ```elixir
    use Transpiler,
      source: {:ast, json: ".rinha/files/fib.json"},
      #        ^     ^     ^ specifies the path to the json file (the path is
      #        ^     ^       relative to your mix.exs file).
      #        ^     ^
      #        ^     ^ specifies that the AST source is a json
      #        ^
      #        ^ specifies that the source is an AST
      parser: Rinha.Parser
    ```

  ### Parsers

  The source might be in whatever type and shape, the important part is that
  the chosen parser should be capable of returning a semantic tree using the
  `Parser.*` structs.

  See `Rinha.Parser` for an example.

  ## Examples

      ```elixir
      defmodule Rinha.Fib do
        use Transpiler,
          source: {:ast, json: "./rinha/files/fib.json},
          parser: Rinha.Parser
      end
      ```

  """

  import File, only: [read!: 1]
  import Jason, only: [decode!: 2]
  import Keyword, only: [get: 2]
  import Macro, only: [escape: 1]
  import Parser, only: [parse!: 2]
  import Transpiler.Node, only: [transpile: 2]

  @doc false
  defmacro __using__(opts) do
    with {:ok, source, ext_resource} <- get(opts, :source) |> maybe_source,
         {:ok, parser} <- get(opts, :parser) |> maybe_parser do
      quote do
        @external_resource unquote(ext_resource)

        {fns, tree} = parse!(unquote(parser), unquote(source))

        for f <- fns do
          Module.eval_quoted(__MODULE__, transpile(f, __MODULE__))
        end

        # tree is a `%Parser.Module{}` struct and  it's transpiled into a
        # `main/0` function
        Module.eval_quoted(__MODULE__, transpile(tree, __MODULE__))
      end
    else
      {:error, msg} ->
        raise ArgumentError,
              message: """
              #{msg}

              Example:

                  ```elixir
                  defmodule Rinha.Fib do
                    use Transpiler,
                      source: {:ast, json: ".rinha/files/fib.json"},
                      parser: Rinha.Parser,
                      transpiler: Rinha.Transpiler
                  end
                  ```

              """
    end
  end

  #
  #   PRIVATE
  #

  defp maybe_parser({:__aliases__, _, [_ | _]} = mod), do: {:ok, mod}
  defp maybe_parser(nil), do: {:error, "expected `#{__MODULE__}` to receive a `parser` option"}
  defp maybe_parser(value), do: {:error, "the `parser` given to `#{__MODULE__}` should be a valid module, got `#{inspect(value)}`"}

  defp maybe_source({:ast, json: path}), do: {:ok, read!(path) |> decode!(keys: :atoms) |> escape, path}
  defp maybe_source(nil), do: {:error, "expected `#{__MODULE__}` to receive a `source` option"}
  defp maybe_source(value), do: {:error, "the `source` given to `#{__MODULE__}` is unsupported, got `#{inspect(value)}`"}
end
