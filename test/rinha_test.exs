defmodule RinhaTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  doctest Rinha.Combination
  doctest Rinha.Fib
  doctest Rinha.Print
  doctest Rinha.Sum

  describe "Binary Add (+) operator" do

    defmodule Sample1 do
      use Transcompiler,
        parser: Parser,
        source: """
        let binary_add = fn (a, b) => { a + b }
        """
    end

    test "works as concatenator when both lhs and rhs are strings" do
      assert Sample1.binary_add("abc", "def")
    end

    test "works as concatenator when lhs is string (rhs is casted to string)" do
      assert Sample1.binary_add("10 * 2 = ", 20)
    end

    test "works as concatenator when rhs is string (lhs is casted to string)" do
      assert Sample1.binary_add(20, " = 10 * 2")
    end

    test "works arithmetic addition when both lhs and rhs are numeric falues" do
      assert Sample1.binary_add(10, 10) == 20
    end

    test "errors with ArithmeticError if lhs/rhs are different than numeric or string" do
      assert_raise(ArithmeticError, fn -> Sample1.binary_add(1, %{}) end)
    end
  end

  describe "parameter default value" do

    defmodule Sample2 do
      use Transcompiler,
        parser: Parser,
        source: """
        let fib = fn (n, a = 0, b = 1) => {
          if (n < 2) {
            if (n < 1) { a } else { b }
          } else {
            fib(n - 1, b, a + b)
          }
        };

        print(fib(10))
        """
    end

    test "can specify default values" do
      assert Sample2.fib(10, 0, 1) == 55
      assert Sample2.fib(10) == 55

      _ = Sample2.fib(100_000)
      #               ^ just proving its fast
    end
  end
end
