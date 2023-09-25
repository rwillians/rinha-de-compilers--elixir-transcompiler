defmodule TranspilableTest do
  use ExUnit.Case, async: true

  defmodule Sample do
    use Transcompiler,
      parser: Parser,
      source: """
      let binary_add = fn (a, b) => { a + b }
      """
  end

  describe "Binary Add (+) operator" do
    test "works as concatenator when both lhs and rhs are strings" do
      assert Sample.binary_add("abc", "def")
    end

    test "works as concatenator when lhs is string (rhs is casted to string)" do
      assert Sample.binary_add("10 * 2 = ", 20)
    end

    test "works as concatenator when rhs is string (lhs is casted to string)" do
      assert Sample.binary_add(20, " = 10 * 2")
    end

    test "works arithmetic addition when both lhs and rhs are numeric falues" do
      assert Sample.binary_add(10, 10) == 20
    end

    test "errors with ArithmeticError if lhs/rhs are different than numeric or string" do
      assert_raise(ArithmeticError, fn -> Sample.binary_add(1, %{}) end)
    end
  end
end
