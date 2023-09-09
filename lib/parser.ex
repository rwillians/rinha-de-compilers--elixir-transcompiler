defmodule Parser do
  @moduledoc false

  @typedoc false
  @type expr() ::
    Parse.BinaryOp.t()
    | Parser.Function.Call.t()
    | Parser.Function.Reference.t()
    | Parser.If.t()
    | Parser.IO.Print.t()
    | Parser.Literal.Boolean.t()
    | Parser.Literal.Integer.t()
    | Parser.Literal.String.t()
    | Parser.Variable.Reference.t()

  @doc """
  A function capable of parsing an entire parse tree.
  """
  @callback parse(value :: term) :: {:ok, parse_tree :: term} | {:error, term}

  @doc """
  A function capable of parsing a list of parse trees.
  """
  @callback parse_many([value :: term]) :: {:ok, [parse_tree :: term]} | {:error, term}

  #

  @doc """
  Takes a parse tree and extracts function definitions from it, returning a
  tuple with a list of function definition in the left side and the rest of
  the tree in the right side.
  """
  @spec split_on_fns(node :: struct) :: {[Parser.Function.t()], node :: struct}

  def split_on_fns(tree) do
    {[], tree}
  end
end
