defmodule Parser do
  @moduledoc false

  import Enum, only: [map: 2]
  import NimbleParsec, except: [map: 2, map: 3]
  import Parser.ErrorHandler, only: [format: 2]

  space = ascii_char([?\s])
  blank = ascii_char([?\r, ?\n, ?\s, ?\t])
  separator = string(",") |> optional(space)

  defcombinatorp :offset, empty() |> pre_traverse(:offset)
  defcombinatorp :ln, empty() |> line()

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
            unwrap_and_tag(parsec(:offset), :start_offset)
            |> unwrap_and_tag(parsec(:ln), :start_line)
            |> unwrap_and_tag(
              choice([
                string("true") |> replace(true),
                string("false") |> replace(false)
              ]),
              :value
            )
            |> unwrap_and_tag(parsec(:ln), :end_line)
            |> unwrap_and_tag(parsec(:offset), :end_offset)
            |> tag(:boolean)

  defparsec :int,
            unwrap_and_tag(parsec(:offset), :start_offset)
            |> unwrap_and_tag(parsec(:ln), :start_line)
            |> unwrap_and_tag(
              choice([
                string("-")
                |> concat(integer(min: 1))
                |> post_traverse(:to_negative_int),
                integer(min: 1)
              ]),
              :value
            )
            |> unwrap_and_tag(parsec(:ln), :end_line)
            |> unwrap_and_tag(parsec(:offset), :end_offset)
            |> tag(:integer)

  defparsec :str,
            unwrap_and_tag(parsec(:offset), :start_offset)
            |> unwrap_and_tag(parsec(:ln), :start_line)
            |> ignore(string(~S(")))
            |> unwrap_and_tag(ascii_string([not: ?"], min: 0), :value)
            |> ignore(string(~S(")))
            |> unwrap_and_tag(parsec(:ln), :end_line)
            |> unwrap_and_tag(parsec(:offset), :end_offset)
            |> tag(:string)

  defparsecp :tuple,
             unwrap_and_tag(parsec(:offset), :start_offset)
             |> unwrap_and_tag(parsec(:ln), :start_line)
             |> ignore(string("("))
             |> ignore(optional(space))
             |> unwrap_and_tag(choice([parsec(:binary_op), parsec(:term)]), :first)
             |> ignore(optional(space))
             |> ignore(string(","))
             |> ignore(optional(space))
             |> unwrap_and_tag(choice([parsec(:binary_op), parsec(:term)]), :second)
             |> ignore(optional(space))
             |> ignore(string(")"))
             |> unwrap_and_tag(parsec(:ln), :end_line)
             |> unwrap_and_tag(parsec(:offset), :end_offset)
             |> tag(:tuple)

  defparsecp :file,
             unwrap_and_tag(parsec(:offset), :start_offset)
             |> unwrap_and_tag(parsec(:ln), :start_line)
             |> tag(repeat(parsec(:expr)), :value)
             |> ignore(eos())
             |> unwrap_and_tag(parsec(:ln), :end_line)
             |> unwrap_and_tag(parsec(:offset), :end_offset)
             |> tag(:file)

  defparsecp :let,
             unwrap_and_tag(parsec(:offset), :start_offset)
             |> unwrap_and_tag(parsec(:ln), :start_line)
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
             |> unwrap_and_tag(parsec(:ln), :end_line)
             |> unwrap_and_tag(parsec(:offset), :end_offset)
             |> tag(:let)

  defparsecp :lambda,
             unwrap_and_tag(parsec(:offset), :start_offset)
             |> unwrap_and_tag(parsec(:ln), :start_line)
             |> ignore(string("fn"))
             |> ignore(repeat(space))
             |> ignore(string("("))
             |> tag(repeat(parsec(:var) |> optional(ignore(separator))), :params)
             |> ignore(string(")"))
             |> ignore(repeat(space))
             |> ignore(string("=>"))
             |> ignore(repeat(space))
             |> unwrap_and_tag(parsec(:block), :block)
             |> unwrap_and_tag(parsec(:ln), :end_line)
             |> unwrap_and_tag(parsec(:offset), :end_offset)
             |> tag(:lambda)

  defparsecp :var,
             unwrap_and_tag(parsec(:offset), :start_offset)
             |> unwrap_and_tag(parsec(:ln), :start_line)
             |> unwrap_and_tag(
               utf8_string([?a..?z], 1)
               |> concat(utf8_string([?a..?z, ?0..?9, ?_], min: 0))
               |> reduce({Enum, :join, [""]}),
               :value
             )
             |> unwrap_and_tag(parsec(:ln), :end_line)
             |> unwrap_and_tag(parsec(:offset), :end_offset)
             |> tag(:var)

  defparsecp :block,
             unwrap_and_tag(parsec(:offset), :start_offset)
             |> unwrap_and_tag(parsec(:ln), :start_line)
             |> tag(
               ignore(string("{"))
               |> ignore(repeat(blank))
               |> repeat(parsec(:expr))
               |> ignore(repeat(blank))
               |> ignore(string("}")),
               :value
             )
             |> unwrap_and_tag(parsec(:ln), :end_line)
             |> unwrap_and_tag(parsec(:offset), :end_offset)
             |> tag(:block)

  defparsecp :if_expr,
             unwrap_and_tag(parsec(:offset), :start_offset)
             |> unwrap_and_tag(parsec(:ln), :start_line)
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
                 empty() |> lookahead_not(string("else")) |> replace(nil)
               ]),
               :otherwise
             )
             |> unwrap_and_tag(parsec(:ln), :end_line)
             |> unwrap_and_tag(parsec(:offset), :end_offset)
             |> tag(:if_expr)

  defparsecp :operator,
             choice([
               string("+") |> lookahead(space) |> replace(:add),
               string("-") |> lookahead(space) |> replace(:sub),
               string("*") |> lookahead(space) |> replace(:mul),
               string("/") |> lookahead(space) |> replace(:div),
               string("%") |> lookahead(space) |> replace(:rem),
               string("==") |> lookahead(space) |> replace(:eq),
               string("!=") |> lookahead(space) |> replace(:neq),
               string("<=") |> lookahead(space) |> replace(:lte),
               string("<") |> lookahead(space) |> replace(:lt),
               string(">=") |> lookahead(space) |> replace(:gte),
               string(">") |> lookahead(space) |> replace(:gt),
               string("&&") |> lookahead(space) |> replace(:and),
               string("||") |> lookahead(space) |> replace(:or),
               empty() |> post_traverse({:error, ["unknown operator"]})
             ])

  defparsecp :binary_op,
             unwrap_and_tag(parsec(:offset), :start_offset)
             |> unwrap_and_tag(parsec(:ln), :start_line)
             |> unwrap_and_tag(parsec(:term), :lhs)
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:operator), :op)
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:term), :rhs)
             |> unwrap_and_tag(parsec(:ln), :end_line)
             |> unwrap_and_tag(parsec(:offset), :end_offset)
             |> tag(:binary_op)

  defparsecp :wrapped_binary_op,
             ignore(string("("))
             |> ignore(repeat(blank))
             |> parsec(:binary_op)
             |> ignore(repeat(blank))
             |> ignore(string(")"))

  defparsecp :call,
             unwrap_and_tag(parsec(:offset), :start_offset)
             |> unwrap_and_tag(parsec(:ln), :start_line)
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
             |> unwrap_and_tag(parsec(:ln), :end_line)
             |> unwrap_and_tag(parsec(:offset), :end_offset)
             |> tag(:call)

  @doc false
  @spec parse(binary, filename :: String.t()) ::
          {:ok, Transcompiler.File.t()}
          | {:error, term}

  def parse(program, filename) do
    case file(program) do
      {:ok, [{:file, exprs}], "", _, _, _} ->
        {:ok, to_common_ast({:file, exprs}, %{filename: filename})}

      {:error, msg, _, _ctx, {line, _}, offset} ->
        msg = format({program, offset}, msg)
        {:error, msg, filename, line}
    end
  end

  #
  # HELPERS
  #

  defp to_negative_int(_rest, [n, "-"], ctx, _line, _offset), do: {[n * -1], ctx}

  defp offset(_rest, _acc, ctx, _line, offset), do: {[offset], ctx}

  defp error(_rest, _acc, _ctx, _line, _offset, msg),
    do: {:error, msg}

  #
  # TO COMMON AST STRUCTS
  #

  defp to_common_ast(nil, _), do: nil

  defp to_common_ast(
         {:loc,
          {{{_, {start_line, start_line_offset}}, start_offset},
           {{_, {end_line, end_line_offset}}, end_offset}}},
         ctx
       ) do
    %AST.Location{
      filename: ctx.filename,
      start: %AST.Location.Placement{
        offset: start_offset,
        line: start_line,
        line_offset: start_offset - start_line_offset
      },
      end: %AST.Location.Placement{
        offset: end_offset,
        line: end_line,
        line_offset: end_offset - end_line_offset
      }
    }
  end

  defp to_common_ast(
         {:file,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:value, exprs},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.File{
      name: ctx.filename,
      block: map(exprs, &to_common_ast(&1, ctx)),
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end

  defp to_common_ast(
         {:block,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:value, exprs},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.Block{
      exprs: map(exprs, &to_common_ast(&1, ctx)),
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end

  defp to_common_ast(
         {:let,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:var, name},
            {:value, value},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.Let{
      var: to_common_ast(name, ctx),
      value: to_common_ast(value, ctx),
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end

  defp to_common_ast(
         {:lambda,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:params, params},
            {:block, block},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.Lambda{
      params: map(params, &to_common_ast(&1, ctx)),
      block: to_common_ast(block, ctx),
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end

  defp to_common_ast(
         {:call,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:callee, [{:var, _} = var]},
            {:args, args},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.Call{
      callee: to_common_ast(var, ctx),
      args: map(args, &to_common_ast(&1, ctx)),
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end

  defp to_common_ast(
         {:if_expr,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:condition, condition},
            {:then, then},
            {:otherwise, otherwise},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.If{
      condition: to_common_ast(condition, ctx),
      then: to_common_ast(then, ctx),
      otherwise: to_common_ast(otherwise, ctx),
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end

  defp to_common_ast(
         {:binary_op,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:lhs, lhs},
            {:op, op},
            {:rhs, rhs},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    fields = %{
      lhs: to_common_ast(lhs, ctx),
      rhs: to_common_ast(rhs, ctx),
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }

    case op do
      :add -> struct(AST.BinaryOp.Add, fields)
      :sub -> struct(AST.BinaryOp.Sub, fields)
      :mul -> struct(AST.BinaryOp.Mul, fields)
      :div -> struct(AST.BinaryOp.Div, fields)
      :rem -> struct(AST.BinaryOp.Rem, fields)
      :eq -> struct(AST.BinaryOp.Eq, fields)
      :neq -> struct(AST.BinaryOp.Neq, fields)
      :lt -> struct(AST.BinaryOp.Lt, fields)
      :gt -> struct(AST.BinaryOp.Gt, fields)
      :lte -> struct(AST.BinaryOp.Lte, fields)
      :gte -> struct(AST.BinaryOp.Gte, fields)
      :and -> struct(AST.BinaryOp.And, fields)
      :or -> struct(AST.BinaryOp.Or, fields)
    end
  end

  defp to_common_ast(
         {:var,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:value, name},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.Variable{
      name: String.to_atom(name),
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end

  defp to_common_ast(
         {:integer,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:value, value},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.Integer{
      value: value,
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end

  defp to_common_ast(
         {:boolean,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:value, value},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.Boolean{
      value: value,
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end

  defp to_common_ast(
         {:string,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:value, value},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.String{
      value: value,
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end

  defp to_common_ast(
         {:tuple,
          [
            {:start_offset, start_offset},
            {:start_line, start_line},
            {:first, first},
            {:second, second},
            {:end_line, end_line},
            {:end_offset, end_offset}
          ]},
         ctx
       ) do
    %AST.Tuple{
      first: to_common_ast(first, ctx),
      second: to_common_ast(second, ctx),
      location: to_common_ast({:loc, {{start_line, start_offset}, {end_line, end_offset}}}, ctx)
    }
  end
end
