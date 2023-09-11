defmodule Transcompiler.Parser do
  @moduledoc false

  import NimbleParsec

  empty_space = ascii_string([?\r, ?\n, ?\s], min: 1)
  maybe_empty_space = ascii_string([?\r, ?\n, ?\s], min: 0)
  param_separator = string(",")

  int = integer(min: 1) |> unwrap_and_tag(:integer)
  str = string(~S(")) |> ascii_string([not: ?"], min: 0) |> string(~S(")) |> unwrap_and_tag(:string)
  bool = choice([string("true") |> replace(true), string("false") |> replace(false) ]) |> unwrap_and_tag(:boolean)

  defparsecp :literal,
    choice([
      int,
      str,
      bool
    ])

  defparsecp :varname,
    utf8_string([?a..?z], 1)
    |> concat(utf8_string([?a..?z, ?0..?9, ?_], min: 0))
    |> reduce({Enum, :join, [""]})
    |> tag(:varname)
    |> label(
      """
      Variable name must follow these rules:

          1. must start with a lower-case letter (a-z);
          2. must contain only lower-case letters, numbers (0-9) and underscore (_).

      """
    ),
    export_metadata: true

  defparsecp :let,
    ignore(string("let "))
    |> unwrap_and_tag(parsec(:varname), :name)
    |> optional(ignore(string(" ")))
    |> ignore(string("="))
    |> optional(ignore(maybe_empty_space))
    |> unwrap_and_tag(parsec(:expr), :value)
    |> ignore(string(";"))
    |> tag(:let),
    export_metadata: true

  defparsecp :fn,
    ignore(string("fn ("))
    |> tag(times(parsec(:varname) |> optional(ignore(param_separator) |> ignore(maybe_empty_space)), min: 0), :params)
    |> ignore(string(") => "))
    |> unwrap_and_tag(parsec(:block), :block)
    |> tag(:fn),
    export_metadata: true

  defparsec :if,
    ignore(string("if ("))
    |> tag(parsec(:expr), :condition)
    |> ignore(string(") "))
    |> tag(parsec(:block), :then)
    |> ignore(string(" else "))
    |> tag(parsec(:block), :otherwise)
    |> tag(:if)

  defparsecp :block,
    ignore(string("{"))
    |> ignore(maybe_empty_space)
    |> parsec(:expr)
    |> ignore(maybe_empty_space)
    |> ignore(string("}"))

  defparsecp :call,
    tag(parsec(:varname), :callee)
    |> ignore(string("("))
    |> tag(ascii_string([not: ?\)], min: 1), :args)
    # |> tag(times(parsec(:term) |> optional(ignore(string(",") |> optional(maybe_empty_space))), min: 0), :args)
    |> ignore(string(")"))
    |> tag(:call)

  defparsecp :operator,
    choice([
      string("+") |> replace(:add),
      string("-") |> replace(:sub),
      string("<") |> replace(:lt)
    ])
    |> lookahead(string(" "))

  defparsecp :binary_op,
      empty()
      |> tag(parsec(:term), :lhs)
      |> ignore(string(" "))
      |> tag(parsec(:operator), :op)
      |> ignore(string(" "))
      |> tag(parsec(:term), :lhs)
      |> tag(:binary_op)

  # things that can be tossed around as value
  defparsecp :term,
      choice([
        parsec(:call),
        parsec(:varname),
        parsec(:literal),
        parsec(:binary_op)
      ])

  defparsecp :expr,
    empty()
    |> choice([
      parsec(:let),
      parsec(:binary_op),
      parsec(:if),
      parsec(:fn),
      parsec(:call),
      parsec(:varname),
      ignore(empty_space),
      # ascii_string([], min: 0),
    ]),
    export_metadata: true

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
    {:ok, acc, rest, _, _ ,_} = expr(@program)

    IO.inspect(acc)

    IO.inspect(rest)

    :ok

    # fn_call("fib(n)")
    # parse_if("""
    # if (n < 2) {
    #   n
    # } else {
    #   fib(n - 1) + fib(n - 2)
    # }
    # """)
  end

  def parse(""), do: {:ok, []}

  def parse(program) do
    with {:ok, acc, rest, _, _, _} <- expr(program),
         {:ok, more} <- parse(rest),
         do: {:ok, acc ++ more}
  end

  #

  # defp varname(_rest, %{}, context, _line, _offset) do
  #   # {[String.to_atom(List.to_string(prefix) <> suffix)], context}
  # end
end
