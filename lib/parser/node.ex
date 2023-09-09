defprotocol Parser.Node do
  @moduledoc false

  @doc """
  A function that transforms the json ast for a node into a struct representing
  the respective type of the node.
  """
  @spec parse(node :: map) :: {:ok, struct} | {:error, term}

  def parse(node)
end
