defmodule Rinha.Print do
  @moduledoc """

  ## Examples

      iex> capture_io(fn -> Rinha.Print.main() end)
      "Hello world\\n"

  """
  use Transcompiler,
    source: {:file, path: ".rinha/files/print.rinha"},
    parser: Rinha.Parser
end
