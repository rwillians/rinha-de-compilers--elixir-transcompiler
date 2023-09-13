{path, n} =
  case System.argv() do
    [<<_, _::binary>> = path] ->
      {path, 1}

    [<<_, _::binary>> = path, n] ->
      {path, String.to_integer(n)}

    _ ->
      raise ArgumentError,
            message: """
            missing arguments

            Usage:  mix run play.exs path [n]

              path  Relative path to a `.rinha` program.

                 n  The number of times the program should be executed
                    (meant for benchmarking).
            """
  end

ast =
  File.read!(path)
  |> Rinha.Parser.parse(path)
  |> Ex.Tuple.unwrap!()
  |> Transcompiler.transpile(Play)

ast =
  {:defmodule, [imports: [{2, Kernel}]], [
    {:__aliases__, [alias: false], [:Play]},
    [do: ast]
  ]}

[{_mod, _bin}] = Code.compile_quoted(ast, "::in-line")

cond do
  n > 1 -> for(_ <- 0..(n), do: Play.main())
  true -> Play.main()
end
