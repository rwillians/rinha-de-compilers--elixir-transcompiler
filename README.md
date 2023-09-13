<div align="center">
  <a href="https://github.com/aripiprazole/rinha-de-compiler" alt="Link para o repositório da Rinha de Compiladores" target="_blank">
    <img src="https://raw.githubusercontent.com/aripiprazole/rinha-de-compiler/main/img/banner.png" alt="Logo da Rinha de Compilers">
  </a>
</div>

---

# A Source-to-Source Transcompiler

The core idea here is to use Elixir (at compile time) to parse a `.rinha` program, transpile it to Elixir AST and then compile it as an Elixir program.


## How to use it?

You just need to create a module where your transpiled `rinha` program will live. To transpcompile the code, all you gotta do is use the `Transcompile` module:

```elixir
# lib/rinha/fib.ex

defmodule Rinha.Fib do
  use Transcompiler,
    source: {:file, path: ".rinha/files/fib.rinha"},
    parser: Rinha.Parser
end

```

All functions defined in your `.rinha` program file will be extracted from the syntax tree then transpiled as Elixir's `def` functions (public module functions). That's necessary to allow for recursive functions. As for the rest of the tree, all script-like procedural code will be transpiled into a `main/0` public function in the same module.


## Running it

> **Note**
> I assume you have `asdf-vm` installed (because you should 👀 -- it's like nvm, but for anything basically).

1.  Clone the repo (yes, that `--recursive` flag is important):

    ```sh
    git clone --recursive git@github.com:rwillians/rinha-de-compiladores.git
    ```

2.  Install Elixir and Erlang with the versions specified in the file `.tool-versions`:

    ```sh
    asdf install
    ```

3.  Install dependencies:

    ```sh
    mix deps.get
    ```

4.  Compile dependencies (shouldn't be timmed):

    ```sh
    mix deps.compile
    ```

5.  Compile the main source code (that's the one you want to time):

    ```sh
    mix compile
    ```

6.  run the REPL:

    ```sh
    iex -S mix
    ```

7.  Call whatever function you'd like to see working:

    ```elixir
    Rinha.Fib.main()
    ```

    Note that functions specified in the program are public functions, meaning you could call `fib/1` from the REPL as well:

    ```elixir
    Rinha.Fib.fib(15)
    ```

    You can also play with the other test programs:

    ```elixir
    Rinha.Combination.main()
    ```

    ```elixir
    Rinha.Sum.main()
    ```


## How does it work?

Let's take `Rinha.Fib` as an example:

```elixir
# lib/rinha/fib.ex

defmodule Rinha.Fib do
  use Transcompiler,
    source: {:file, path: ".rinha/files/fib.rinha"},
    parser: Rinha.Parser
end
```

When you use `use Transcompiler`, we first take that `path` to the `fib.rinha` program and make sure it's associated with your módule (e.g.: `Rinha.Fib`) so that, whenever `fib.rinha` is changed, then the módulo is recompiled:

```elixir
# lib/transcompiler.ex

defmodule Transcompiler do
  # ...

  defmacro __using__(opts) do
    # ...

    quote do
      @external_resource unquote(path)

      # ...
    end
  end

  # ...
end
```

Then the contents of `fib.rinha` is read and parsed into a generic AST:

```elixir
# lib/transcompiler.ex

defmodule Transcompiler do
  #...

  defmacro __using__(opts) do
    # ...

    quote do
      # ...

      ast = File.read!(unquote(path))
            #   ^  read the contents of the file

            |> unquote(parser).parse(unquote(path))
            #  ^ calls function `parse/2` from the `parser`
            #    given when using `use Transcompiler`

            # |> Ex.Tuple.unwrap!()
            # |> unquote(__MODULE__).transpile(__MODULE__)

      # ...
    end
  end

  # ...
end
```

The parser is implemented using [NimbleParsed](https://github.com/dashbitco/nimble_parsec) for parser combinators that are compiled to functions where rules are choosen via pattern matching (meaning, it's fast!):

```elixir
# lib/rinha/parser.ex

defmodule Rinha.Parser do
  # ...

  defparsec :bool,
            choice([
              string("true") |> replace(true),
              string("false") |> replace(false)
            ])
            |> unwrap_and_tag(:boolean)

  defparsecp :let,
             ignore(string("let"))
             |> ignore(times(space, min: 1))
             |> parsec(:var)
             |> ignore(times(space, min: 1))
             |> ignore(string("="))
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:expr), :value)
             |> ignore(optional(string(";")))
             |> tag(:let)

  defparsecp :binary_op,
             empty()
             |> unwrap_and_tag(parsec(:term), :lhs)
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:operator), :op)
             |> ignore(times(space, min: 1))
             |> unwrap_and_tag(parsec(:term), :rhs)
             |> tag(:binary_op)

  # ...

  def parse(program, filename) do
    with {:ok, [{:file, exprs}], "", _, _, _} <- file(program),
         do: {:ok, to_common_ast({:file, exprs}, %{filename: filename})}
  end

  # ...

  defp to_common_ast({:string, value}, ctx) do
    %Transcompiler.String{
      value: value,
      location: %Transcompiler.Location{filename: ctx.filename}
    }
  end
end
```

Parsing a program results in a generic AST like this:

```elixir
# "let a = k == 0;"
%Transcompiler.File{
  name: "foo.rinha",
  block: [
    %Transcompiler.Let{
      var: %Transcompiler.Variable{name: :a, location: %Transcompiler.Location{}},
      value: %Transcompiler.BinaryOp.Eq{
        lhs: %Transcompiler.Variable{name: :k, location: %Transcompiler.Location{}},
        rhs: %Transcompiler.Integer{value: 0, location: %Transcompiler.Location{}},
        location: %Transcompiler.Location{}
      },
      location: %Transcompiler.Location{}
    }
  ],
  location: %Transcompiler.Location{}
}
```

There's a total of 27 types of tokens that can be composed into that generic AST. Each token implements a `Transpiler` protocol, which introduces the function `to_elixir_ast` that is capable of taking a specific type of AST node and recursively transpile it to Elixir AST.

```elixir
# lib/transcompiler/transpiler.ex
defprotocol Transcompiler.Transpiler do
  @spec to_elixir_ast(ast :: struct, env :: module) :: Macro.t()
  def to_elixir_ast(ast, env)
end
```

```elixir
lib/transcompiler/binary_op.add.ex
defimpl Transcompiler.Transpiler, for: Transcompiler.BinaryOp.Add do
  def to_elixir_ast(ast, env) do
    {:+, [context: env, imports: [{1, Kernel}, {2, Kernel}]], [
      Transcompiler.Transpiler.to_elixir_ast(ast.lhs, env),
      Transcompiler.Transpiler.to_elixir_ast(ast.rhs, env),
    ]}
  end
end
```

Now that we have a generic AST and that we're capable of transpiling it to Elixir AST, let's get back to `Transcompiler` module. It takes the generic AST and transpiles it to Elixir AST then apply such AST to the module which invoked `use Transcompile`:

```elixir
# lib/transcompiler.ex

defmodule Transcompiler do
  # ...

  defmacro __using__(opts) do
    # ...

    quote do
      # ...

      ast = File.read!(unquote(path))
            #    ^ read the contents for `fib.rinha`

            |> unquote(parser).parse(unquote(path))
            #                  ^ parses into generic AST

            |> Ex.Tuple.unwrap!()
            #          ^ raises and error if something goes wrong
            #            with parsing

            |> unquote(__MODULE__).transpile(__MODULE__)
            #                      ^ recursively transpiles generic
            #                        AST into Elixir AST

      Module.eval_quoted(__MODULE__, ast)
      #     ^ applies Elixir AST to the module which invoked
      #       `use Transcompiler`
    end
  end

  # ...
end
```

And that's it. Now the `.rinha` code is Elixir code; get's compiled as Elixir code and runs as beam-vm's code using ERTS (Erlang's Runtime System).


## Where to find me

|      Name | Link                                                 |
|----------:|:-----------------------------------------------------|
| 𝕏 Twitter | [@rwillians_](https://twitter.com/rwillians_)        |
|  LinkedIn | [@rwillians](https://www.linkedin.com/in/rwillians/) |
|    GitHub | [@rwillians](https://github.com/rwillians)           |
|    Resume | [rwillians.com](https://rwillians.com/resume)        |


## What's next?

- [ ] `#debug` add line number and character offset to `Transcompiler.Location` on all tokens;
- [ ] `#improvement` support functions to be declared anywhere in the file, not only at the root scope;
- [ ] `#dx` `#debug` provide nicer error messages when parsing fails.
