defmodule Transcompiler.Parser2 do
  @moduledoc false

  import NimbleParsec

  space = ascii_string([?\s], min: 1)
  blank = ascii_string([?\r, ?\n, ?\s], min: 1)

  bool = choice([string("true") |> replace(true), string("false") |> replace(false)])
  int = integer(min: 1)
  str = ignore(string(~S("))) |> ascii_string([not: ?"], min: 0) |> ignore(string(~S(")))

  defparsecp :literal,
    choice([
      unwrap_and_tag(bool, :boolean),
      unwrap_and_tag(int, :integer),
      unwrap_and_tag(str, :string)
    ])

  defcombinatorp :varname,
    utf8_string([?a..?z], 1)
    |> concat(utf8_string([?a..?z, ?0..?9, ?_], min: 0))
    |> reduce({Enum, :join, [""]})

  defparsecp :operator,
    choice([
      string("==") |> replace(:eq),
      string("||") |> replace(:or),
      string("<")  |> replace(:lt),
      string("+")  |> replace(:add),
      string("-")  |> replace(:sub)
    ])
    |> lookahead(string(" "))

  defparsecp :let,
    ignore(string("let"))
    |> ignore(space)
    |> unwrap_and_tag(parsec(:varname), :varname)
    |> ignore(space)
    |> ignore(string("="))
    |> ignore(blank)
    |> unwrap_and_tag(parsec(:expr), :value)
    |> optional(ignore(string(";")))
    |> tag(:let)

  defparsecp :fn,
    ignore(string("fn"))
    |> ignore(space)
    |> ignore(string("("))
    |> tag(repeat(parsec(:varname) |> optional(ignore(string(",") |> optional(blank)))), :params)
    |> ignore(string(")"))
    |> ignore(space)
    |> ignore(string("=>"))
    |> ignore(space)
    |> tag(parsec(:block), :block)
    |> tag(:fn)

  defparsecp :block,
    empty()
    |> ignore(string("{"))
    |> ignore(blank)
    |> repeat(parsec(:expr) |> optional(ignore(blank)))
    |> ignore(string("}"))

  defparsecp :if,
    ignore(string("if"))
    |> ignore(space)
    |> ignore(string("("))
    |> tag(parsec(:binary_op), :condition)
    |> ignore(string(")"))
    |> ignore(blank)
    |> tag(parsec(:block), :then)
    |> ignore(blank)
    |> ignore(string("else"))
    |> ignore(blank)
    |> tag(parsec(:block), :otherwise)
    |> tag(:if)

  defparsecp :call,
    empty()
    |> unwrap_and_tag(parsec(:varname), :fn)
    |> ignore(string("("))
    |> tag(repeat(choice([parsec(:binary_op), parsec(:term)]) |> optional(ignore(string(",") |> optional(space)))), :args)
    |> ignore(string(")"))
    |> tag(:call)

  defcombinatorp :binary_op,
    parsec(:term)
    |> ignore(space)
    |> concat(parsec(:operator))
    |> ignore(space)
    |> concat(parsec(:term))
    |> tag(:binary_op)

  defcombinatorp :term,
    choice([
      parsec(:call),
      unwrap_and_tag(parsec(:varname), :varname),
      parsec(:literal),
      ignore(string("(")) |> parsec(:binary_op) |> ignore(string(")"))
    ])

  defcombinatorp :expr,
    empty()
    |> choice([
      parsec(:let),
      parsec(:fn),
      parsec(:if),
      parsec(:binary_op),
      parsec(:term)
    ])
    |> optional(ignore(blank))

  defparsec :parse, repeat(parsec(:expr))

  def test_fib do
    parse("""
    let fib = fn (n) => {
      if (n < 2) {
        n
      } else {
        fib(n - 1) + fib(n - 2)
      }
    };

    print(fib(10))
    """)
  end

  def test_combination do
    parse("""
    let combination = fn (n, k) => {
      let a = k == 0;
      let b = k == n;
      if (a || b)
      {
          1
      }
      else {
          combination(n - 1, k - 1) + combination(n - 1, k)
      }
    };

    print(combination(10, 2))
    """)
  end
end
