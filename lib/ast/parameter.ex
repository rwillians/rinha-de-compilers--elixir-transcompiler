defmodule AST.Parameter do
  @moduledoc false

  @typedoc false
  @type t :: %AST.Parameter{
          var: AST.Variable.t(),
          default_value: AST.ast_term() | nil,
          location: AST.Location.t()
        }
  defstruct [:var, :location, default_value: nil]
end

defimpl Transpilable, for: AST.Parameter do
  def to_elixir_ast(%{default_value: :undefined} = ast, env),
    do: {ast.var.name, [file: ast.location.filename, line: ast.location.start.line], env}

  def to_elixir_ast(ast, env) do
    {:\\, [], [
      {ast.var.name, [file: ast.location.filename, line: ast.location.start.line], env},
      Transpilable.to_elixir_ast(ast.default_value, env)
    ]}
  end
end
