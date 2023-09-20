defmodule Rinha.Combination do
  @moduledoc """

  ## Examples

  ### `combination/2`:

    iex> assert   1 == Rinha.Combination.combination(0, 0)
    iex> assert   1 == Rinha.Combination.combination(1, 1)
    iex> assert   5 == Rinha.Combination.combination(5, 1)
    iex> assert  10 == Rinha.Combination.combination(5, 2)
    iex> assert  45 == Rinha.Combination.combination(10, 2)
    iex> assert 120 == Rinha.Combination.combination(10, 3)

  ### `main/0`:

    iex> capture_io(fn -> Rinha.Combination.main() end)
    "45\\n"

  """
  use Transcompiler,
    source: {:file, path: ".rinha/files/combination.rinha"},
    parser: Parser
end
