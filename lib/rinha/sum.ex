defmodule Rinha.Sum do
  use Transcompiler,
    source: {:file, path: ".rinha/files/sum.rinha"},
    parser: Rinha.Parser
end
