defmodule Rinha.Sum do
  @moduledoc """

  ## Examples

  ### `sum/1`:

    iex> assert  1 == Rinha.Sum.sum(1)
    iex> assert  3 == Rinha.Sum.sum(2)
    iex> assert 10 == Rinha.Sum.sum(4)
    iex> assert 15 == Rinha.Sum.sum(5)
    iex> assert 55 == Rinha.Sum.sum(10)

  ### `main/0`

      iex> capture_io(fn -> Rinha.Sum.main() end)
      "15\\n"

  """
  use Transcompiler,
    source: {:file, path: ".rinha/files/sum.rinha"},
    parser: Parser
end
