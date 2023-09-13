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


## Where to find me

|      Name | Link                                                 |
|----------:|:-----------------------------------------------------|
| 𝕏 Twitter | [@rwillians_](https://twitter.com/rwillians_)        |
|  LinkedIn | [@rwillians](https://www.linkedin.com/in/rwillians/) |
|    GitHub | [@rwillians](https://github.com/rwillians)           |
|    Resume | [rwillians.com](https://rwillians.com/resume)        |
