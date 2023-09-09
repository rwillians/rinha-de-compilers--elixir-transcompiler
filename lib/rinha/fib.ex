defmodule Rinha.Fib do
  use Transpiler,
    source: {:ast, json: ".rinha/files/fib.json"},
    parser: Rinha.Parser
end
