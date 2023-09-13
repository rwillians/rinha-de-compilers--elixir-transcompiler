defmodule Rinha.Combination do
  use Transcompiler,
    source: {:file, path: ".rinha/files/combination.rinha"},
    parser: Rinha.Parser
end
