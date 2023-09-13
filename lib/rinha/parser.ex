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

  defparsecp :lambda,
             ignore(string("fn"))
             |> ignore(repeat(space))
             |> ignore(string("("))
             |> tag(repeat(parsec(:var) |> optional(ignore(separator))), :params)
             |> ignore(string(")"))
             |> ignore(repeat(space))
             |> ignore(string("=>"))
             |> ignore(repeat(space))
             |> tag(parsec(:block), :block)
             |> tag(:lambda)

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

  defparsecp :wrapped_binary_op,
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
               parsec(:wrapped_binary_op),
               parsec(:tuple),
               parsec(:bool),
               parsec(:int),
               parsec(:str),
               parsec(:lambda),
               parsec(:call),
               parsec(:var)
             ])

  defparsecp :expr,
             choice([
               parsec(:let),
               parsec(:if),
               parsec(:lambda),
               parsec(:binary_op),
               parsec(:term)
             ])
             |> ignore(repeat(blank))

  @doc false
  @spec parse(binary, filename :: String.t()) ::
          {:ok, Transcompiler.File.t()}
          | {:error, term}

  def parse(program, filename) do
    with {:ok, [{:file, exprs}], "", _, _, _} <- file(program),
         do: {:ok, to_common_ast({:file, exprs}, %{filename: filename})}
  end

  #
  # HELPERS
  #

  defp to_negative_int(_rest, [n, "-"], ctx, _line, _offset), do: {[n * -1], ctx}

  #
  # TO COMMON AST STRUCTS
  #

  defp to_common_ast({:file, exprs}, ctx) do
    %Transcompiler.File{
      name: ctx.filename,
      block: Enum.map(exprs, &to_common_ast(&1, ctx)),
      location: %Transcompiler.File{name: ctx.filename}
    }
  end

  defp to_common_ast({:let, [{:var, name}, {:value, {:lambda, _} = lambda}]}, ctx) do
    lambda = to_common_ast(lambda, ctx)

    %Transcompiler.Function{
      name: String.to_atom(name),
      params: lambda.params,
      block: lambda.block,
      location: %Transcompiler.File{name: ctx.filename}
    }
  end

  defp to_common_ast({:let, [{:var, name}, {:value, value}]}, ctx) do
    location = %Transcompiler.File{name: ctx.filename}

    %Transcompiler.Let{
      var: %Transcompiler.Variable{name: String.to_atom(name), location: location},
      value: to_common_ast(value, ctx),
      location: location
    }
  end

  defp to_common_ast({:lambda, [{:params, params}, {:block, exprs}]}, ctx) do
    %Transcompiler.Lambda{
      params: Enum.map(params, &to_common_ast(&1, ctx)),
      block: Enum.map(exprs, &to_common_ast(&1, ctx)),
      location: %Transcompiler.File{name: ctx.filename}
    }
  end

  defp to_common_ast({:call, [{:callee, [{:var, name}]}, {:args, args}]}, ctx) do
    %Transcompiler.Call{
      callee: String.to_atom(name),
      args: Enum.map(args, &to_common_ast(&1, ctx)),
      location: %Transcompiler.File{name: ctx.filename}
    }
  end

  defp to_common_ast({:if, [{:condition, condition}, {:then, then}, {:otherwise, otherwise}]}, ctx) do
    %Transcompiler.If{
      condition: to_common_ast(condition, ctx),
      then: Enum.map(then, &to_common_ast(&1, ctx)),
      otherwise: Enum.map(otherwise, &to_common_ast(&1, ctx)),
      location: %Transcompiler.File{name: ctx.filename}
    }
  end

  defp to_common_ast({:binary_op, [{:lhs, lhs}, {:op, op}, {:rhs, rhs}]}, ctx) do
    fields = %{
      lhs: to_common_ast(lhs, ctx),
      rhs: to_common_ast(rhs, ctx),
      location: %Transcompiler.File{name: ctx.filename}
    }

    case op do
      :add -> struct(Transcompiler.BinaryOp.Add, fields)
      :sub -> struct(Transcompiler.BinaryOp.Sub, fields)
      :mul -> struct(Transcompiler.BinaryOp.Mul, fields)
      :div -> struct(Transcompiler.BinaryOp.Div, fields)
      :rem -> struct(Transcompiler.BinaryOp.Rem, fields)
      :eq  -> struct(Transcompiler.BinaryOp.Eq, fields)
      :neq -> struct(Transcompiler.BinaryOp.Neq, fields)
      :lt  -> struct(Transcompiler.BinaryOp.Lt, fields)
      :gt  -> struct(Transcompiler.BinaryOp.Gt, fields)
      :lte -> struct(Transcompiler.BinaryOp.Lte, fields)
      :gte -> struct(Transcompiler.BinaryOp.Gte, fields)
      :and -> struct(Transcompiler.BinaryOp.And, fields)
      :or  -> struct(Transcompiler.BinaryOp.Or, fields)
    end
  end

  defp to_common_ast({:var, name}, ctx) do
    %Transcompiler.Variable{
      name: String.to_atom(name),
      location: %Transcompiler.File{name: ctx.filename}
    }
  end

  defp to_common_ast({:integer, value}, ctx) do
    %Transcompiler.Integer{
      value: value,
      location: %Transcompiler.File{name: ctx.filename}
    }
  end

  defp to_common_ast({:boolean, value}, ctx) do
    %Transcompiler.Boolean{
      value: value,
      location: %Transcompiler.File{name: ctx.filename}
    }
  end

  defp to_common_ast({:string, value}, ctx) do
    %Transcompiler.String{
      value: value,
      location: %Transcompiler.File{name: ctx.filename}
    }
  end

  defp to_common_ast({:tuple, [{:first, first}, {:second, second}]}, ctx) do
    %Transcompiler.Tuple{
      first: to_common_ast(first, ctx),
      second: to_common_ast(second, ctx),
      location: %Transcompiler.File{name: ctx.filename}
    }
  end
end
