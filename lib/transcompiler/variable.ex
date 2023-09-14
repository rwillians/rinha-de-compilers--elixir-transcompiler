defmodule Transcompiler.Variable do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Variable{
          name: atom,
          location: Transcompiler.Location.t()
        }
  defstruct [:name, :location]
end

defimpl Transpilable, for: Transcompiler.Variable do
  def to_elixir_ast(ast, env), do: {ast.name, [], env}
end
