defprotocol Rinha.Parser.Node do
  @moduledoc false

  @fallback_to_any true

  @doc """
  A function capable of parsing the given value into a struct specific for a
  node type.
  """
  @spec parse(node :: t, value :: map) :: {:ok, node :: t} | {:error, term}

  def parse(node \\ Any, value)

  @doc """
  A function capable of parsing many values of the given struct.
  """
  @spec parse_many(node :: t, [value :: map]) :: {:ok, [node :: t]} | {:error, term}

  def parse_many(node \\ Any, values)
end

#
#   ANY / FALLBACK
#

defimpl Rinha.Parser.Node, for: Any do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(_, %{kind: "Let", value: %{kind: "Function"}} = node), do: p(Parser.Function, node)
  def parse(_, %{kind: "If"} = node), do: p(Parser.If, node)
  def parse(_, %{kind: "Binary", op: _} = node), do: p(Parser.BinaryOp, node)
  def parse(_, %{kind: "Var"} = node), do: p(Parser.Variable.Reference, node)
  def parse(_, %{kind: "Int"} = node), do: p(Parser.Literal.Integer, node)
  def parse(_, %{kind: "Str"} = node), do: p(Parser.Literal.String, node)
  def parse(_, %{kind: "Bool"} = node), do: p(Parser.Literal.Boolean, node)
  def parse(_, %{kind: "Call"} = node), do: p(Parser.Function.Call, node)
  def parse(_, %{kind: "Print"} = node), do: p(Parser.IO.Print, node)

  def parse(_, expr) do
    raise CompileError,
          message: """
          Unable to transpile unknown expression:

              ```
              #{expr}
              ```
          """
  end
end

#
#   LOCATION
#

defimpl Rinha.Parser.Node, for: Parser.Location do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(location, %{
        filename: <<_, _::binary>> = name,
        start: char_start,
        end: char_end
      }) do
    {:ok, %{location | filename: name, start: char_start, end: char_end}}
  end
end

#
#   FILE
#

defimpl Rinha.Parser.Node, for: Parser.File do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(struct, %{
        name: <<_, _::binary>> = name,
        expression: expr,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, expr} <- p(expr) do
      {:ok, %{struct | name: name, expr: expr, location: location}}
    end
  end
end

#
#   FUNCTION NAME
#

defimpl Rinha.Parser.Node, for: Parser.Function.Name do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(struct, %{
        text: text,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{struct | text: text, location: location}}
    end
  end
end

#
#   FUNCTION PARAMETER
#

defimpl Rinha.Parser.Node, for: Parser.Function.Parameter do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(struct, %{
        text: name,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{struct | name: name, location: location}}
    end
  end
end

#
#   IF
#

defimpl Rinha.Parser.Node, for: Parser.If do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(struct, %{
        kind: "If",
        condition: condition,
        then: then,
        otherwise: otherwise,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, condition} <- p(condition),
         {:ok, then} <- p(then),
         {:ok, otherwise} <- p(otherwise) do
      {:ok,
       %{struct | condition: condition, then: then, otherwise: otherwise, location: location}}
    end
  end
end

#
#   BINARY OP
#

defimpl Rinha.Parser.Node, for: Parser.BinaryOp do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(binary_op, %{
        kind: "Binary",
        lhs: lhs,
        op: op,
        rhs: rhs,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, op} <- cast_op(op),
         {:ok, lhs} <- p(lhs),
         {:ok, rhs} <- p(rhs) do
      {:ok, %{binary_op | lhs: lhs, op: op, rhs: rhs, location: location}}
    end
  end

  defp cast_op("Eq"), do: {:ok, :eq}
  defp cast_op("Ne"), do: {:ok, :ne}
  defp cast_op("Lt"), do: {:ok, :lt}
  defp cast_op("Gt"), do: {:ok, :gt}
  defp cast_op("Lte"), do: {:ok, :lte}
  defp cast_op("Gte"), do: {:ok, :gte}
  defp cast_op("Add"), do: {:ok, :add}
  defp cast_op("Sub"), do: {:ok, :sub}
  defp cast_op("Div"), do: {:ok, :div}
end

#
#   VARIABLE REFERENCE
#

defimpl Rinha.Parser.Node, for: Parser.Variable.Reference do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(ref, %{
        kind: "Var",
        text: name,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{ref | name: name, location: location}}
    end
  end
end

#
#   LITERAL / INTEGER
#

defimpl Rinha.Parser.Node, for: Parser.Literal.Integer do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(literal, %{
        kind: "Int",
        value: value,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{literal | value: value, location: location}}
    end
  end
end

#
#   LITERAL / STRING
#

defimpl Rinha.Parser.Node, for: Parser.Literal.String do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(literal, %{
        kind: "Str",
        value: value,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{literal | value: value, location: location}}
    end
  end
end

#
#   LITERAL / BOOLEAN
#

defimpl Rinha.Parser.Node, for: Parser.Literal.Boolean do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(literal, %{
        kind: "Bool",
        value: value,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{literal | value: value, location: location}}
    end
  end
end

#
# FUNCTION / DEFINITION
#

defimpl Rinha.Parser.Node, for: Parser.Function do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(struct, %{
        kind: "Let",
        name: name,
        value: %{
          kind: "Function",
          parameters: params,
          value: block,
          location: location
        },
        next: next
      }) do
    with {:ok, name} <- p(Parser.Function.Name, name),
         {:ok, location} <- p(Parser.Location, location),
         {:ok, params} <- pn(Parser.Function.Parameter, params),
         {:ok, block} <- p(block),
         {:ok, next} <- p(next) do
      {:ok, %{struct | name: name, params: params, block: block, location: location, next: next}}
    end
  end
end

defimpl Rinha.Parser.Node, for: Parser.Function.Reference do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(ref, %{
        kind: "Var",
        text: name,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{ref | name: name, location: location}}
    end
  end
end

#
#   FUNCTION / CALL
#

defimpl Rinha.Parser.Node, for: Parser.Function.Call do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(call, %{
        kind: "Call",
        callee: callee,
        arguments: args,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, callee} <- p(Parser.Function.Reference, callee),
         {:ok, args} <- pn(args) do
      {:ok, %{call | callee: callee, args: args, location: location}}
    end
  end
end

#
#   IO / PRINT
#

defimpl Rinha.Parser.Node, for: Parser.IO.Print do
  use Rinha.Parser, derive: [parse_many: 2]

  def parse(print, %{
        kind: "Print",
        value: value,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, value} <- p(value) do
      {:ok, %{print | value: value, location: location}}
    end
  end
end
