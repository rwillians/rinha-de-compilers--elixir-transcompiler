defmodule Transpiler do
  @moduledoc """
  This module is meant to be used (e.g.: `use Transpile`) to indicate that the
  contents of a module will be transpiled from a source other than Elixir. At
  the moment, the only source allowed is the generic AST JSON file published
  for the Rinha de Compilers.
  """

  defmacro __using__(opts) do
    {:ast, json: path} =
      Keyword.get(opts, :source) ||
        raise(ArgumentError, message: """
        expected keyword list provided to #{__MODULE__} to contain key `source` where its value is a tuple like in the example below:

            ```
            defmodule Rinha.Fib do
              use Transpiler,
                source: {:ast, json: ".rinha/files/fib.json"},
                parser: Rinha.Parser
            end
        ```

        """)

    parser =
      Keyword.get(opts, :parser) ||
        raise(ArgumentError, message: """
        expected keyword list provided to `#{__MODULE__}` to contain key `parser` where its value is a module atom like in the example

            ```
            defmodule Rinha.Fib do
              use Transpiler,
                source: {:ast, json: ".rinha/files/fib.json"},
                parser: Rinha.Parser
            end
            ```

        """)

    quote do
      @external_resource unquote(path)

      {fns, tree} = File.read!(@external_resource)
                    |> Jason.decode!(keys: :atoms)
                    |> unquote(parser).parse()
                    |> Parser.split_on_fns

      @tree tree

      def main do
        @tree
      end
    end
  end
end
