defmodule Rinha.Parser do
  @moduledoc false

  @behaviour Parser

  @doc """
  Utility for writing node parsing implementations.
  """
  defmacro __using__([{:derive, [{:parse_many, 2}]}]) do
    quote do
      def parse_many(t, [head | tail]) do
        with {:ok, value} <- parse(t, head),
             do: {:ok, [value] ++ parse_many(t, tail)}
      end

      def parse_many(t, []), do: {:ok, []}

      defoverridable parse_many: 2

      # parse
      defp p(t \\ Any, value)
      defp p(%_{} = t, value), do: Rinha.Parser.Node.parse(t, value)
      defp p(Any, value), do: Rinha.Parser.Node.parse(Any, value)
      defp p(mod, value) when is_atom(mod), do: Rinha.Parser.Node.parse(struct(mod, %{}), value)

      #parse n (many)
      defp pn(t \\ Any, values)
      defp pn(%_{} = t, values), do: Rinha.Parser.Node.parse_many(t, values)
      defp pn(Any, values), do: Rinha.Parser.Node.parse_many(Any, values)
      defp pn(mod, values) when is_atom(mod), do: Rinha.Parser.Node.parse_many(struct(mod, %{}), values)
    end
  end

  @impl Parser
  def parse(%{name: _, expression: _, location: _} = file),
      do: Rinha.Parser.Node.parse(%Parser.File{}, file)

  @impl Parser
  def parse_many([head | tail]) do
    with {:ok, file} <- parse(head),
         do: {:ok, [file] ++ parse_many(tail)}
  end

  def parse_many([]), do: {:ok, []}
end
