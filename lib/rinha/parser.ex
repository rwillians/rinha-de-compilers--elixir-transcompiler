defmodule Rinha.Parser do
  @moduledoc false

  import NimbleParsec

  space = ascii_char([?\s])
  blank = ascii_char([?\r, ?\n, ?\s, ?\t])
  comma = string(",")
  separator = comma |> optional(space)

  defparsec :bool,
            choice([
              string("true") |> replace(true),
              string("false") |> replace(false)
            ])
            |> unwrap_and_tag(:boolean)

  defparsec :int,
            choice([
              string("-")
              |> concat(integer(min: 1))
              |> post_traverse(:to_negative_int),
              integer(min: 1)
            ])
            |> unwrap_and_tag(:integer)

  defparsec :str,
            ignore(string(~S(")))
            |> ascii_string([not: ?"], min: 0)
            |> ignore(string(~S(")))
            |> unwrap_and_tag(:string)

  defparsecp :tuple,
             ignore(string("("))
             |> ignore(optional(space))
             |> unwrap_and_tag(choice([parsec(:binary_op), parsec(:term)]), :first)
             |> ignore(optional(space))
             |> ignore(string(","))
             |> ignore(optional(space))
             |> unwrap_and_tag(choice([parsec(:binary_op), parsec(:term)]), :second)
             |> ignore(optional(space))
             |> ignore(string(")"))
             |> tag(:tuple)

  defparsecp :file,
             repeat(parsec(:expr))
             |> tag(:file)

  defparsecp :let,
             ignore(string("let"))
             |> ignore(times(space, min: 1))
             |> parsec(:var)
             |> ignore(times(space, min: 1))
             |> ignore(string("="))
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:expr), :value)
             |> ignore(optional(string(";")))
             |> tag(:let)

  defparsecp :function,
             ignore(string("fn"))
             |> ignore(repeat(space))
             |> ignore(string("("))
             |> tag(repeat(parsec(:var) |> optional(ignore(separator))), :params)
             |> ignore(string(")"))
             |> ignore(repeat(space))
             |> ignore(string("=>"))
             |> ignore(repeat(space))
             |> tag(parsec(:block), :block)
             |> tag(:function)

  defparsecp :var,
             utf8_string([?a..?z], 1)
             |> concat(utf8_string([?a..?z, ?0..?9, ?_], min: 0))
             |> reduce({Enum, :join, [""]})
             |> unwrap_and_tag(:var)

  defparsecp :block,
             ignore(string("{"))
             |> ignore(repeat(blank))
             |> repeat(parsec(:expr))
             |> ignore(repeat(blank))
             |> ignore(string("}"))

  defparsecp :if,
             ignore(string("if"))
             |> ignore(repeat(space))
             |> ignore(string("("))
             |> unwrap_and_tag(choice([parsec(:binary_op), parsec(:term)]), :condition)
             |> ignore(string(")"))
             |> ignore(repeat(blank))
             |> tag(parsec(:block), :then)
             |> ignore(repeat(blank))
             |> tag(choice([ignore(string("else")) |> ignore(blank) |> parsec(:block), empty() |> replace(nil)]), :otherwise)
             |> tag(:if)

  defparsecp :operator,
             choice([
               string("+") |> replace(:add),
               string("-") |> replace(:sub),
               string("*") |> replace(:mul),
               string("/") |> replace(:div),
               string("%") |> replace(:rem),
               string("==") |> replace(:eq),
               string("!=") |> replace(:neq),
               string("<=") |> replace(:lte),
               string("<") |> replace(:lt),
               string(">=") |> replace(:gte),
               string(">") |> replace(:gt),
               string("&&") |> replace(:and),
               string("||") |> replace(:or)
             ])
             |> lookahead(space)

  defparsecp :binary_op,
             empty()
             |> unwrap_and_tag(parsec(:term), :lhs)
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:operator), :op)
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:term), :rhs)
             |> tag(:binary_op)

  wrapped_binary_op =
    ignore(string("("))
    |> ignore(repeat(blank))
    |> parsec(:binary_op)
    |> ignore(repeat(blank))
    |> ignore(string(")"))

  defparsecp :call,
             tag(parsec(:var), :callee)
             |> ignore(times(space, min: 0))
             |> ignore(string("("))
             |> tag(repeat(choice([parsec(:binary_op), parsec(:term)]) |> ignore(optional(separator))), :args)
             |> ignore(string(")"))
             |> tag(:call)

  defparsecp :term,
             choice([
               parsec(:tuple),
               wrapped_binary_op,
               parsec(:bool),
               parsec(:int),
               parsec(:str),
               # parsec(:tuple),
               parsec(:function),
               parsec(:call),
               parsec(:var)
             ])

  defparsecp :expr,
             choice([
               parsec(:let),
               parsec(:if),
               parsec(:function),
               parsec(:binary_op),
               parsec(:term)
             ])
             |> ignore(repeat(blank))

  @doc false
  @spec parse(filename :: String.t(), binary) ::
          {:ok, Transcompiler.AST.File.t()}
          | {:error, term}

  def parse(filename, program) do
    with {:ok, [{:file, exprs}], "", _, _, _} <- file(program),
         do: {:ok, to_ast({:file, exprs}, %{filename: filename})}
  end

  #
  # HELPERS
  #

  defp to_negative_int(_rest, [n, "-"], ctx, _line, _offset), do: {[n * -1], ctx}

  #
  # TO STRUCTS
  #

  defp to_ast({:file, exprs}, ctx) do
    %Transcompiler.AST.File{
      block: Enum.map(exprs, &to_ast(&1, ctx))
    }
  end

  defp to_ast({:let, [{:var, name}, {:value, value}]}, ctx) do
    %Transcompiler.AST.Let{
      var: String.to_atom(name),
      value: to_ast(value, ctx)
    }
  end

  defp to_ast({:function, [{:params, params}, {:block, exprs}]}, ctx) do
    %Transcompiler.AST.Function{
      params: Enum.map(params, &to_ast(&1, ctx)),
      block: Enum.map(exprs, &to_ast(&1, ctx))
    }
  end

  defp to_ast({:call, [{:callee, [{:var, name}]}, {:args, args}]}, ctx) do
    %Transcompiler.AST.Function.Call{
      callee: String.to_atom(name),
      args: Enum.map(args, &to_ast(&1, ctx))
    }
  end

  defp to_ast({:if, [{:condition, condition}, {:then, then}, {:otherwise, otherwise}]}, ctx) do
    %Transcompiler.AST.If{
      condition: to_ast(condition, ctx),
      then: Enum.map(then, &to_ast(&1, ctx)),
      otherwise: Enum.map(otherwise, &to_ast(&1, ctx))
    }
  end

  defp to_ast({:binary_op, [{:lhs, lhs}, {:op, op}, {:rhs, rhs}]}, ctx) do
    %Transcompiler.AST.BinaryOp{
      lhs: to_ast(lhs, ctx),
      op: op,
      rhs: to_ast(rhs, ctx)
    }
  end

  defp to_ast({:var, name}, _ctx) do
    %Transcompiler.AST.Variable{
      name: String.to_atom(name)
    }
  end

  defp to_ast({:integer, value}, _ctx) do
    %Transcompiler.AST.Integer{
      value: value
    }
  end

  defp to_ast({:boolean, value}, _ctx) do
    %Transcompiler.AST.Boolean{
      value: value
    }
  end

  defp to_ast({:string, value}, _ctx) do
    %Transcompiler.AST.String{
      value: value
    }
  end

  defp to_ast({:tuple, [{:first, first}, {:second, second}]}, ctx) do
    %Transcompiler.AST.Tuple{
      first: to_ast(first, ctx),
      second: to_ast(second, ctx)
    }
  end
end
