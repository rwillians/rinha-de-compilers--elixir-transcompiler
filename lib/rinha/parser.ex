defmodule Rinha.Parser do
  @moduledoc false

  import NimbleParsec
  import Rinha.Parser.ErrorHandler, only: [format: 3]

  space = ascii_char([?\s])
  blank = ascii_char([?\r, ?\n, ?\s, ?\t])
  separator = string(",") |> optional(space)

  defcombinatorp :loc, empty() |> pre_traverse(:loc)

  defcombinatorp :term,
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
               parsec(:if_expr),
               parsec(:lambda),
               parsec(:binary_op),
               parsec(:term)
             ])
             |> ignore(repeat(blank))

  defparsec :bool,
            unwrap_and_tag(parsec(:loc), :start)
            |> unwrap_and_tag(
              choice([
                string("true") |> replace(true),
                string("false") |> replace(false)
              ]),
              :value
            )
            |> unwrap_and_tag(parsec(:loc), :end)
            |> unwrap_and_tag(:boolean)

  defparsec :int,
            unwrap_and_tag(parsec(:loc), :start)
            |> unwrap_and_tag(
              choice([
                string("-")
                |> concat(integer(min: 1))
                |> post_traverse(:to_negative_int),
                integer(min: 1)
              ]),
              :value
            )
            |> unwrap_and_tag(parsec(:loc), :end)
            |> tag(:integer)

  defparsec :str,
            unwrap_and_tag(parsec(:loc), :start)
            |> ignore(string(~S(")))
            |> unwrap_and_tag(ascii_string([not: ?"], min: 0), :value)
            |> ignore(string(~S(")))
            |> unwrap_and_tag(parsec(:loc), :end)
            |> tag(:string)

  defparsecp :tuple,
             unwrap_and_tag(parsec(:loc), :start)
             |> ignore(string("("))
             |> ignore(optional(space))
             |> unwrap_and_tag(choice([parsec(:binary_op), parsec(:term)]), :first)
             |> ignore(optional(space))
             |> ignore(string(","))
             |> ignore(optional(space))
             |> unwrap_and_tag(choice([parsec(:binary_op), parsec(:term)]), :second)
             |> ignore(optional(space))
             |> ignore(string(")"))
             |> unwrap_and_tag(parsec(:loc), :end)
             |> tag(:tuple)

  defparsecp :file,
             unwrap_and_tag(parsec(:loc), :start)
             |> tag(repeat(parsec(:expr)), :value)
             |> ignore(eos())
             |> unwrap_and_tag(parsec(:loc), :end)
             |> tag(:file)

  defparsecp :let,
             unwrap_and_tag(parsec(:loc), :start)
             |> ignore(string("let"))
             |> ignore(times(space, min: 1))
             |> choice([
               unwrap_and_tag(parsec(:var), :var),
               empty() |> post_traverse({:error, ["expected variable name to be specified"]})
             ])
             |> ignore(times(space, min: 1))
             |> ignore(string("="))
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:expr), :value)
             |> ignore(optional(string(";")))
             |> unwrap_and_tag(parsec(:loc), :end)
             |> tag(:let)

  defparsecp :lambda,
             unwrap_and_tag(parsec(:loc), :start)
             |> ignore(string("fn"))
             |> ignore(repeat(space))
             |> ignore(string("("))
             |> tag(repeat(parsec(:var) |> optional(ignore(separator))), :params)
             |> ignore(string(")"))
             |> ignore(repeat(space))
             |> ignore(string("=>"))
             |> ignore(repeat(space))
             |> unwrap_and_tag(parsec(:block), :block)
             |> unwrap_and_tag(parsec(:loc), :end)
             |> tag(:lambda)

  defparsecp :var,
             unwrap_and_tag(parsec(:loc), :start)
             |> unwrap_and_tag(
               utf8_string([?a..?z], 1)
               |> concat(utf8_string([?a..?z, ?0..?9, ?_], min: 0))
               |> reduce({Enum, :join, [""]}),
               :value
             )
             |> unwrap_and_tag(parsec(:loc), :end)
             |> tag(:var)

  defparsecp :block,
             unwrap_and_tag(parsec(:loc), :start)
             |> tag(
               ignore(string("{"))
               |> ignore(repeat(blank))
               |> repeat(parsec(:expr))
               |> ignore(repeat(blank))
               |> ignore(string("}")),
               :value
             )
             |> unwrap_and_tag(parsec(:loc), :end)
             |> tag(:block)

  defparsecp :if_expr,
             unwrap_and_tag(parsec(:loc), :start)
             |> ignore(string("if"))
             |> ignore(repeat(space))
             |> ignore(string("("))
             |> unwrap_and_tag(choice([parsec(:binary_op), parsec(:term)]), :condition)
             |> ignore(string(")"))
             |> ignore(repeat(blank))
             |> unwrap_and_tag(parsec(:block), :then)
             |> ignore(repeat(blank))
             |> unwrap_and_tag(
               choice([
                 ignore(string("else")) |> ignore(blank) |> parsec(:block),
                 empty() |> replace(nil)
               ]),
               :otherwise
             )
             |> unwrap_and_tag(parsec(:loc), :end)
             |> tag(:if_expr)

  defparsecp :operator,
             choice([
               string("+") |> replace(:add),
               string("-") |> replace(:sub),
               string("*") |> replace(:mul),
               string("/") |> replace(:div),
               string("%") |> replace(:rem),
               string("==") |> lookahead(space) |> replace(:eq),
               string("!=") |> replace(:neq),
               string("<=") |> replace(:lte),
               string("<") |> lookahead(space) |> replace(:lt),
               string(">=") |> replace(:gte),
               string(">") |> lookahead(space) |> replace(:gt),
               string("&&") |> replace(:and),
               string("||") |> replace(:or),
               empty() |> post_traverse({:error, ["unknown operator"]})
             ])

  defparsecp :binary_op,
             unwrap_and_tag(parsec(:loc), :start)
             |> unwrap_and_tag(parsec(:term), :lhs)
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:operator), :op)
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:term), :rhs)
             |> unwrap_and_tag(parsec(:loc), :end)
             |> tag(:binary_op)

  defparsecp :wrapped_binary_op,
             ignore(string("("))
             |> ignore(repeat(blank))
             |> parsec(:binary_op)
             |> ignore(repeat(blank))
             |> ignore(string(")"))

  defparsecp :call,
             unwrap_and_tag(parsec(:loc), :start)
             |> tag(parsec(:var), :callee)
             |> ignore(times(space, min: 0))
             |> ignore(string("("))
             |> tag(
               repeat(
                 choice([
                   parsec(:binary_op),
                   parsec(:term)
                 ])
                 |> ignore(optional(separator))
               ),
               :args
             )
             |> ignore(string(")"))
             |> unwrap_and_tag(parsec(:loc), :end)
             |> tag(:call)

  @doc false
  @spec parse(binary, filename :: String.t()) ::
          {:ok, Transcompiler.File.t()}
          | {:error, term}

  def parse(program, filename) do
    case file(program) do
      {:ok, [{:file, exprs}], "", _, _, _} ->
        {:ok, to_common_ast({:file, exprs}, %{filename: filename})}

      {:error, msg, _, ctx, line, offset} ->
        throw({:error, msg, ctx, line, offset})
    end
  catch
    {:error, msg, _ctx, _line, offset} ->
      {msg, line_number} = format(msg, program, offset)
      {:error, msg, filename, line_number}
  end

  #
  # HELPERS
  #

  defp to_negative_int(_rest, [n, "-"], ctx, _line, _offset), do: {[n * -1], ctx}

  defp loc(_rest, _acc, ctx, _line, offset), do: {[offset], ctx}

  #
  # ERRORS
  #

  defp error(_rest, _acc, ctx, line, offset, msg) do
    throw({:error, msg, ctx, line, offset})
  end

  #
  # TO COMMON AST STRUCTS
  #

  defp to_common_ast(nil, _), do: nil

  defp to_common_ast({:loc, {loc_start, loc_end}}, ctx) do
    %Transcompiler.Location{
      filename: ctx.filename,
      start: loc_start,
      end: loc_end
    }
  end

  defp to_common_ast(
         {:file, [{:start, loc_start}, {:value, exprs}, {:end, loc_end}]},
         ctx
       ) do
    %Transcompiler.File{
      name: ctx.filename,
      block: Enum.map(exprs, &to_common_ast(&1, ctx)),
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:block, [{:start, loc_start}, {:value, exprs}, {:end, loc_end}]},
         ctx
       ) do
    %Transcompiler.Block{
      exprs: Enum.map(exprs, &to_common_ast(&1, ctx)),
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:let,
          [
            {:start, loc_start},
            {:var, var},
            {:value, {:lambda, _} = lambda},
            {:end, loc_end}
          ]},
         ctx
       ) do
    lambda = to_common_ast(lambda, ctx)

    %Transcompiler.Function{
      var: to_common_ast(var, ctx),
      params: lambda.params,
      block: lambda.block,
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:let,
          [
            {:start, loc_start},
            {:var, name},
            {:value, value},
            {:end, loc_end}
          ]},
         ctx
       ) do
    %Transcompiler.Let{
      var: to_common_ast(name, ctx),
      value: to_common_ast(value, ctx),
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:lambda,
          [
            {:start, loc_start},
            {:params, params},
            {:block, block},
            {:end, loc_end}
          ]},
         ctx
       ) do
    %Transcompiler.Lambda{
      params: Enum.map(params, &to_common_ast(&1, ctx)),
      block: to_common_ast(block, ctx),
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:call,
          [
            {:start, loc_start},
            {:callee, [{:var, _} = var]},
            {:args, args},
            {:end, loc_end}
          ]},
         ctx
       ) do
    %Transcompiler.Call{
      callee: to_common_ast(var, ctx),
      args: Enum.map(args, &to_common_ast(&1, ctx)),
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:if_expr,
          [
            {:start, loc_start},
            {:condition, condition},
            {:then, then},
            {:otherwise, otherwise},
            {:end, loc_end}
          ]},
         ctx
       ) do
    %Transcompiler.If{
      condition: to_common_ast(condition, ctx),
      then: to_common_ast(then, ctx),
      otherwise: to_common_ast(otherwise, ctx),
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:binary_op,
          [
            {:start, loc_start},
            {:lhs, lhs},
            {:op, op},
            {:rhs, rhs},
            {:end, loc_end}
          ]},
         ctx
       ) do
    fields = %{
      lhs: to_common_ast(lhs, ctx),
      rhs: to_common_ast(rhs, ctx),
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }

    case op do
      :add -> struct(Transcompiler.BinaryOp.Add, fields)
      :sub -> struct(Transcompiler.BinaryOp.Sub, fields)
      :mul -> struct(Transcompiler.BinaryOp.Mul, fields)
      :div -> struct(Transcompiler.BinaryOp.Div, fields)
      :rem -> struct(Transcompiler.BinaryOp.Rem, fields)
      :eq -> struct(Transcompiler.BinaryOp.Eq, fields)
      :neq -> struct(Transcompiler.BinaryOp.Neq, fields)
      :lt -> struct(Transcompiler.BinaryOp.Lt, fields)
      :gt -> struct(Transcompiler.BinaryOp.Gt, fields)
      :lte -> struct(Transcompiler.BinaryOp.Lte, fields)
      :gte -> struct(Transcompiler.BinaryOp.Gte, fields)
      :and -> struct(Transcompiler.BinaryOp.And, fields)
      :or -> struct(Transcompiler.BinaryOp.Or, fields)
    end
  end

  defp to_common_ast(
         {:var, [{:start, loc_start}, {:value, name}, {:end, loc_end}]},
         ctx
       ) do
    %Transcompiler.Variable{
      name: String.to_atom(name),
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:integer, [{:start, loc_start}, {:value, value}, {:end, loc_end}]},
         ctx
       ) do
    %Transcompiler.Integer{
      value: value,
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:boolean, [{:start, loc_start}, {:value, value}, {:end, loc_end}]},
         ctx
       ) do
    %Transcompiler.Boolean{
      value: value,
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:string, [{:start, loc_start}, {:value, value}, {:end, loc_end}]},
         ctx
       ) do
    %Transcompiler.String{
      value: value,
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end

  defp to_common_ast(
         {:tuple, [{:start, loc_start}, {:first, first}, {:second, second}, {:end, loc_end}]},
         ctx
       ) do
    %Transcompiler.Tuple{
      first: to_common_ast(first, ctx),
      second: to_common_ast(second, ctx),
      location: to_common_ast({:loc, {loc_start, loc_end}}, ctx)
    }
  end
end
