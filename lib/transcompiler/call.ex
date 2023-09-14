defmodule Transcompiler.Call do
  @moduledoc false

  @typedoc false
  @type t :: %Transcompiler.Call{
          callee: fn_name :: atom,
          args: [Transcompiler.Term.t()],
          location: Transcompiler.Location.t()
        }
  defstruct [:callee, :args, :location]
end

defimpl Transpilable, for: Transcompiler.Call do
  def to_elixir_ast(%{callee: %{name: :print}} = ast, env) do
    args = Enum.map(ast.args, &Transpilable.to_elixir_ast(&1, env))

    {{:., [], [{:__aliases__, [alias: false], [:IO]}, :puts]}, [],
     [{:to_string, [context: env, imports: [{1, Kernel}]], args}]}
  end

  def to_elixir_ast(%{callee: %{name: :first}} = ast, env) do
    args = Enum.map(ast.args, &Transpilable.to_elixir_ast(&1, env))

    {:elem, [context: Play, imports: [{2, Kernel}]], args ++ [0]}
  end

  def to_elixir_ast(%{callee: %{name: :second}} = ast, env) do
    args = Enum.map(ast.args, &Transpilable.to_elixir_ast(&1, env))

    {:elem, [context: Play, imports: [{2, Kernel}]], args ++ [1]}
  end

  def to_elixir_ast(ast, env) do
    args = Enum.map(ast.args, &Transpilable.to_elixir_ast(&1, env))

    {ast.callee.name, [context: env], args}
  end
end
