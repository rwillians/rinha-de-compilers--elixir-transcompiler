defmodule Transcompiler.Parser2 do
  @moduledoc false

  import NimbleParsec

  space = ascii_string([?\s], min: 1)
  blank = ascii_string([?\r, ?\n, ?\s], min: 1)
  rest = ascii_string([], min: 0)

  bool = choice([string("true") |> replace(true), string("false") |> replace(false)])
  int = integer(min: 1)
  str = ignore(string(~S("))) |> ascii_string([not: ?"], min: 0) |> ignore(string(~S(")))

  defcombinatorp :literal,
    choice([bool, int, str])

  defcombinatorp :varname,
    utf8_string([?a..?z], 1)
    |> concat(utf8_string([?a..?z, ?0..?9, ?_], min: 0))
    |> reduce({Enum, :join, [""]})
    |> unwrap_and_tag(:varname)

  defparsecp :let,
    ignore(string("let"))
    |> ignore(space)
    |> parsec(:varname)
    |> ignore(space)
    |> ignore(string("="))
    |> ignore(blank)
    |> unwrap_and_tag(parsec(:expr), :value)
    |> tag(:let)

  defparsecp :fn,
    ignore(string("fn"))
    |> ignore(space)
    |> ignore(string("("))
    |> tag(repeat(wrap(parsec(:varname) |> optional(string(",") |> optional(blank)))), :args)
    |> ignore(string(")"))
    |> ignore(space)
    |> ignore(string("=>"))
    |> ignore(space)
    |> tag(rest, :block)
    |> tag(:fn)

  defcombinatorp :expr,
    empty()
    |> choice([
      parsec(:let),
      parsec(:fn),
      parsec(:varname)
    ])
    |> optional(ignore(blank))
    |> repeat()

  defparsec :parse, parsec(:expr)

  @program """
  let fib = fn (n) => {
    if (n < 2) {
      n
    } else {
      fib(n - 1) + fib(n - 2)
    }
  };

  print(fib(10))
  """

  def main do
    parse(@program)
  end
end
