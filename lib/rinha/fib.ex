defmodule Rinha.Fib do
  @moduledoc """

  ## Examples

  ### `fib/1`:

      iex> assert  1 == Rinha.Fib.fib(1)
      iex> assert  1 == Rinha.Fib.fib(2)
      iex> assert  2 == Rinha.Fib.fib(3)
      iex> assert  3 == Rinha.Fib.fib(4)
      iex> assert  5 == Rinha.Fib.fib(5)
      iex> assert 55 == Rinha.Fib.fib(10)

  ### `main/0`:

      iex> capture_io(fn -> Rinha.Fib.main() end)
      "55\\n"

  """
  use Transcompiler,
    source: {:file, path: ".rinha/files/fib.rinha"},
    parser: Parser
end
