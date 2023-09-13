defmodule Rinha.Fib do
  use Transcompiler,
    source: {:file, path: ".rinha/files/fib.rinha"},
    parser: Rinha.Parser
end
