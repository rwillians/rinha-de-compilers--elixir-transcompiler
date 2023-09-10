defmodule RinhaTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  doctest Rinha.Combination
  doctest Rinha.Fib
end
