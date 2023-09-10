defmodule Rinha.Combination do
  use Transpiler,
    source: {:ast, json: ".rinha/files/combination.json"},
    parser: Rinha.Parser
end
