{path, n} =
  case System.argv() do
    [<<_, _::binary>> = path] ->
      {path, 1}

    [<<_, _::binary>> = path, n] ->
      {path, String.to_integer(n)}

    _ ->
      faint = IO.ANSI.faint()
      reset = IO.ANSI.reset()
      bold = "\e[1m"

      raise ArgumentError,
            message: """
            missing arguments

            #{faint}#{bold}Usage:#{reset}  mix run play.exs path [n]

              #{faint}#{bold}path#{reset}  #{faint}Relative path to a `.rinha` program.#{reset}

                 #{faint}#{bold}n#{reset}  #{faint}The number of times the program should be executed
                    (meant for benchmarking).#{reset}

            """
  end

result = File.read!(path) |> Parser.parse(path)

block =
  case result do
    {:ok, expr} ->
      Transpilable.to_elixir_ast(expr, __MODULE__)

    {:error, msg, file, line} ->
      raise CompileError,
            file: file,
            line: line,
            description: msg
  end

ast =
  {:defmodule, [imports: [{2, Kernel}]], [
    {:__aliases__, [alias: false], [:Play]},
    [do: block]
  ]}

[{_mod, _bin}] = Code.compile_quoted(ast, "::in-line")

cond do
  n > 1 -> for(_ <- 0..(n), do: Play.main())
  true -> Play.main()
end
