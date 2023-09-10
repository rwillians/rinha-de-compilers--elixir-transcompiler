defmodule Rinha.Combination do
  @moduledoc """

  ## Examples

  ### `Rinha.Combination.combination/2`:

      iex> assert      1 == Rinha.Combination.combination(0, 0)
      iex> assert      1 == Rinha.Combination.combination(1, 1)
      iex> assert      2 == Rinha.Combination.combination(2, 1)
      iex> assert      6 == Rinha.Combination.combination(4, 2)
      iex> assert     45 == Rinha.Combination.combination(10, 2)
      iex> assert 184756 == Rinha.Combination.combination(20, 10)

  ### `Rinha.Combination.main/0`:

      iex> capture_io(fn -> Rinha.Combination.main() end)
      "45\\n"

  """
  use Transpiler,
    source: {:ast, json: ".rinha/files/combination.json"},
    parser: Rinha.Parser
end
