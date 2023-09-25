defmodule AST.BinaryOp.Add do
  @moduledoc false

  @typedoc false
  @type t :: %AST.BinaryOp.Add{
          lhs: AST.ast_term(),
          rhs: AST.ast_term(),
          location: AST.Location.t()
        }
  defstruct [:lhs, :rhs, :location]
end

defimpl Transpilable, for: AST.BinaryOp.Add do
  def to_elixir_ast(ast, env) do
    meta = [
      context: env,
      file: ast.location.filename,
      line: ast.location.start.line
    ]

    lhs = Transpilable.to_elixir_ast(ast.lhs, env)
    rhs = Transpilable.to_elixir_ast(ast.rhs, env)

    {:case, [],
     [
       {lhs, rhs},
       [
         do: [
           {:->, meta,
            [
              [
                {
                  {:=, [], [{:<<>>, [], [{:"::", [], [{:_, [], env}, {:binary, [], env}]}]}, {:a, [], env}]},
                  {:=, [], [{:<<>>, [], [{:"::", [], [{:_, [], env}, {:binary, [], env}]}]}, {:b, [], env}]}
                }
              ],
              {:<>, [{:imports, [{2, Kernel}]} | meta], [{:a, [], env}, {:b, [], env}]}
            ]},
           {:->, meta,
            [
              [
                {
                  {:=, [], [{:<<>>, [], [{:"::", [], [{:_, [], env}, {:binary, [], env}]}]}, {:a, [], env}]},
                  {:b, [], env}}
              ],
              {:<>, [{:imports, [{2, Kernel}]} | meta],
               [
                 {:a, [], env},
                 {:to_string, [{:imports, [{1, Kernel}]} | meta], [{:b, [], env}]}
               ]}
            ]},
           {:->, [],
            [
              [
                {{:a, [], env},
                 {:=, [], [{:<<>>, [], [{:"::", [], [{:_, [], env}, {:binary, [], env}]}]}, {:b, [], env}]}}
              ],
              {:<>, [{:imports, [{2, Kernel}]} | meta],
               [
                 {:to_string, [imports: [{1, Kernel}]], [{:a, [], env}]},
                 {:b, [], env}
               ]}
            ]},
           {:->, [],
            [
              [{{:a, [], env}, {:b, [], env}}],
              {:+, [{:imports, [{1, Kernel}, {2, Kernel}]} | meta],
               [
                 {:a, [], env},
                 {:b, [], env}
               ]}
            ]}
         ]
       ]
     ]}
  end

  #
  # PRIVATE
  #

  # defp concat(a, b, meta)
end
