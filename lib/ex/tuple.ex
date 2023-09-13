defmodule Ex.Tuple do
  @moduledoc """
  Extended functionalities for the `Tuple` module.
  """

  @doc """
  Unwraps the value from a success result, otherwise raises an error.
  """
  def unwrap!({:ok, value}), do: value
end
