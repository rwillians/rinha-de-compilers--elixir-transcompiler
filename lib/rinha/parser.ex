defprotocol Rinha.Parser do
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

###############################################################################
#                               ANY / FALLBACK                                #
###############################################################################

defimpl Rinha.Parser, for: Any do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(Any, %{kind: "Let", value: %{kind: "Function"}} = node), do: p(Parser.Function.Definition, node)
  def parse(Any, %{kind: "Let"} = node), do: p(Parser.Variable.Definition, node)
  def parse(Any, %{kind: "If"} = node), do: p(Parser.If, node)
  def parse(Any, %{kind: "Binary", op: _} = node), do: p(Parser.BinaryOp, node)
  def parse(Any, %{kind: "Var"} = node), do: p(Parser.Variable.Reference, node)
  def parse(Any, %{kind: "Int"} = node), do: p(Parser.Literal.Integer, node)
  def parse(Any, %{kind: "Str"} = node), do: p(Parser.Literal.String, node)
  def parse(Any, %{kind: "Bool"} = node), do: p(Parser.Literal.Boolean, node)
  def parse(Any, %{kind: "Call"} = node), do: p(Parser.Function.Call, node)
  def parse(Any, %{kind: "Print"} = node), do: p(Parser.IO.Print, node)
end

###############################################################################
#                                   BASICS                                    #
###############################################################################

#
#   MODULE
#

defimpl Rinha.Parser, for: Parser.Module do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(struct, %{
        name: <<_, _::binary>> = name,
        expression: block,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, block} <- p(Any, block) do
      {:ok, %{struct | name: name, block: block, location: location}}
    end
  end
end

#
#   LOCATION
#

defimpl Rinha.Parser, for: Parser.Location do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(location, %{
        filename: <<_, _::binary>> = name,
        start: char_start,
        end: char_end
      }) do
    {:ok, %{location | filename: name, start: char_start, end: char_end}}
  end
end

#
#   NAME
#

defimpl Rinha.Parser, for: Parser.Name do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(struct, %{
        text: text,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{struct | text: String.to_atom(text), location: location}}
    end
  end
end

###############################################################################
#                                  FUNCTIONS                                  #
###############################################################################

#
#   PARAMETER
#

defimpl Rinha.Parser, for: Parser.Function.Parameter do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(struct, %{
        text: name,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{struct | name: String.to_atom(name), location: location}}
    end
  end
end

#
#   DEFINITION
#

defimpl Rinha.Parser, for: Parser.Function.Definition do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(definition, %{
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
    with {:ok, name} <- p(Parser.Name, name),
         {:ok, location} <- p(Parser.Location, location),
         {:ok, params} <- pn(Parser.Function.Parameter, params),
         {:ok, block} <- p(Any, block),
         {:ok, next} <- p(Any, next) do
      {:ok, %{definition | name: name, params: params, block: block, location: location, next: next}}
    end
  end
end

#
#   REFERENCE
#

defimpl Rinha.Parser, for: Parser.Function.Reference do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(ref, %{
        kind: "Var",
        text: name,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{ref | name: String.to_atom(name), location: location}}
    end
  end
end

#
#   CALL
#

defimpl Rinha.Parser, for: Parser.Function.Call do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(call, %{
        kind: "Call",
        callee: callee,
        arguments: args,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, callee} <- p(Parser.Function.Reference, callee),
         {:ok, args} <- pn(Any, args) do
      {:ok, %{call | callee: callee, args: args, location: location}}
    end
  end
end

###############################################################################
#                                FLOW CONTROL                                 #
###############################################################################

#
#   IF
#

defimpl Rinha.Parser, for: Parser.If do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(struct, %{
        kind: "If",
        condition: condition,
        then: then,
        otherwise: otherwise,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, condition} <- p(Parser.BinaryOp, condition),
         {:ok, then} <- p(Any, then),
         {:ok, otherwise} <- p(Any, otherwise) do
      {:ok,
       %{struct | condition: condition, then: then, otherwise: otherwise, location: location}}
    end
  end
end

###############################################################################
#                              BINARY OPERATIONS                              #
###############################################################################

defimpl Rinha.Parser, for: Parser.BinaryOp do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  @mapping %{
    "Eq" => :eq,
    "Ne" => :ne,
    "Lt" => :lt,
    "Gt" => :gt,
    "Lte" => :lte,
    "Gte" => :gte,
    "Add" => :add,
    "Sub" => :sub,
    "Div" => :div,
    "Or" => :or
  }

  @keys Map.keys(@mapping)

  def parse(binary_op, %{
        kind: "Binary",
        lhs: lhs,
        op: op,
        rhs: rhs,
        location: location
      })
      when op in @keys do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, op} <- cast(op),
         {:ok, lhs} <- p(Any, lhs),
         {:ok, rhs} <- p(Any, rhs) do
      {:ok, %{binary_op | lhs: lhs, op: op, rhs: rhs, location: location}}
    end
  end

  for {str, atom} <- @mapping do
    def cast(unquote(str)), do: {:ok, unquote(atom)}
  end
end

###############################################################################
#                                  VARIABLES                                  #
###############################################################################

#
#   DEFINITION
#

defimpl Rinha.Parser, for: Parser.Variable.Definition do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(var, %{
        kind: "Let",
        name: name,
        value: value,
        location: location,
        next: next
      }) do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, name} <- p(Parser.Name, name),
         {:ok, value} <- p(Any, value),
         {:ok, next} <- p(Any, next) do
      {:ok, %{var | name: name, value: value, location: location, next: next}}
    end
  end
end

#
#   REFERENCE
#

defimpl Rinha.Parser, for: Parser.Variable.Reference do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(ref, %{
        kind: "Var",
        text: name,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location) do
      {:ok, %{ref | name: String.to_atom(name), location: location}}
    end
  end
end

###############################################################################
#                                  LITERALS                                   #
###############################################################################

#
#   BOOLEAN
#

defimpl Rinha.Parser, for: Parser.Literal.Boolean do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

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
#   INTEGER
#

defimpl Rinha.Parser, for: Parser.Literal.Integer do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

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
#   STRING
#

defimpl Rinha.Parser, for: Parser.Literal.String do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

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

###############################################################################
#                                      IO                                     #
###############################################################################

#
#   PRINT
#

defimpl Rinha.Parser, for: Parser.IO.Print do
  use Parser,
    protocol: Rinha.Parser,
    derive: [parse_many: 2]

  def parse(print, %{
        kind: "Print",
        value: value,
        location: location
      }) do
    with {:ok, location} <- p(Parser.Location, location),
         {:ok, value} <- p(Any, value) do
      {:ok, %{print | value: value, location: location}}
    end
  end
end
