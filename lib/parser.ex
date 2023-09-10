defmodule Parser do
  @moduledoc false

  @doc """
  Utility for writing parser implementations.
  """
  defmacro __using__([{:protocol, protocol}, {:derive, [{:parse_many, 2}]}]) do
    quote do
      def parse_many(t, [head | tail]) do
        with {:ok, value} <- parse(t, head),
             {:ok, values} <- parse_many(t, tail),
             do: {:ok, [value] ++ values}
      end

      def parse_many(t, []), do: {:ok, []}

      defoverridable parse_many: 2

      # parse
      defp p(%_{} = t, value), do: unquote(protocol).parse(t, value)
      defp p(Any, value), do: unquote(protocol).parse(Any, value)
      defp p(mod, value) when is_atom(mod), do: unquote(protocol).parse(struct(mod, []), value)

      # parse n (many)
      defp pn(%_{} = t, values), do: unquote(protocol).parse_many(t, values)
      defp pn(Any, values), do: unquote(protocol).parse_many(Any, values)
      defp pn(mod, values) when is_atom(mod), do: unquote(protocol).parse_many(struct(mod, []), values)
    end
  end

  @doc """
  A function that, given a parser, can parse the `value` into a `Parser.Module`.
  """
  @spec parse(parser :: module, value :: term) ::
    {:ok, [Parser.Function.Definition.t()], Parser.Module.t()} | {:error, term}

  def parse(parser, value) do
    with {:ok, tree} <- apply(parser, :parse, [%Parser.Module{}, value]),
         {fns, tree} <- split_fns_from_tree(tree),
         do: {:ok, fns, tree}
  end

  @doc """
  Same as `parse/2`, but raises an error if something goes wrong.
  """
  @spec parse(parser :: module, value :: term) ::
    {[Parser.Function.Definition.t()], Parser.Module.t()}

  def parse!(parser, value) do
    {:ok, fns, tree} = parse(parser, value)
    {fns, tree}
  end

  #

  defp split_fns_from_tree(%Parser.Module{} = tree), do: {extract_fns(tree), exclude_fns(tree)}

  defp extract_fns(acc \\ [], node)
  defp extract_fns(acc, %Parser.Module{block: next}), do: extract_fns(acc, next)
  defp extract_fns(acc, %Parser.Function.Definition{} = node), do: extract_fns([%{node | next: nil} | acc], node.next)
  defp extract_fns(acc, %_{next: next}), do: extract_fns(acc, next)
  defp extract_fns(acc, _), do: :lists.reverse(acc)

  defp exclude_fns(%Parser.Module{block: next} = node), do: %{node | block: exclude_fns(next)}
  defp exclude_fns(%Parser.Function.Definition{} = node), do: exclude_fns(node.next)
  defp exclude_fns(%_{next: next} = node), do: %{node | next: exclude_fns(next)}
  defp exclude_fns(node), do: node
end
