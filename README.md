<div align="center">
  <a href="https://github.com/aripiprazole/rinha-de-compiler" alt="Link para o repositório da Rinha de Compiladores" target="_blank">
    <img src="https://raw.githubusercontent.com/aripiprazole/rinha-de-compiler/main/img/banner.png" alt="Logo da Rinha de Compilers">
  </a>
</div>

---

# A Source-to-Source Transcompiler written in Elixir

Fancy names apart, the core idea here is that we take a program `.rinha`, parse it, transpile it to Elixir AST and then compile it as its own module.


# Usage

Elixir/Erlang doesn't compile down to a single executable binary, sorry. Because
of that, I'll suggest 3 ways of using this code:

1. Run from a docker image;
2. Build your own docker image (in case of platform compatiblity issues); and
3. Install and run everything locally.

## Run from a docker image

You need to add a volume with the programs you want to run. In this example,
I'm mouting `./examples` directory from the root of this project into
`/data/programs` directory, inside the container.

Then all is needed is to run the desired program:

```sh
docker run \
  --mount type=bind,source="/absolut/path/to/rinha/files",target="/data" \
  -it ghcr.io/rwillians/rinha-de-compilers--elixir-transcompiler:latest \
  run play.exs /data/fib.rinha
```

You may also specify how many times you want the program to be executed.
Compiles once, executes the program `n` times.

```sh
docker run \
  --mount type=bind,source="/absolut/path/to/rinha/files",target="/data" \
  -it ghcr.io/rwillians/rinha-de-compilers--elixir-transcompiler:latest \
  run play.exs /data/fib.rinha 100
```

## Building the docker image locally

You should only have to do this if there's a compatibility problema for builds
targeting your platform of use.

Steps are pretty simple:

```sh
docker build -t ghcr.io/rwillians/rinha-de-compilers--elixir-transcompiler:latest .
```

That should do the trick. You can now move back to the previous sections and resume from there.


## Running all locally

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

With that out of the way, you can now run programs with:

```sh
mix run play.exs .rinha/files/fib.rinha 1000 &>/dev/nul
#                ^ path to the `.rinha` program you want to run
```
