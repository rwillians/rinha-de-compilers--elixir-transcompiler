<div align="center">
  <a href="https://github.com/aripiprazole/rinha-de-compiler" alt="Link para o repositório da Rinha de Compiladores" target="_blank">
    <img src="https://raw.githubusercontent.com/aripiprazole/rinha-de-compiler/main/img/banner.png" alt="Logo da Rinha de Compilers">
  </a>
</div>

---

# A Source-to-Source Transcompiler written in Elixir

Fancy names apart, the core idea here is that we take a program `.rinha`, parse it, transpile it to Elixir AST and then compile it as its own module.


## Instructions for the competition's organizers on how to run it

You might opt for using a pre-built image:

```sh
docker pull ghcr.io/rwillians/rinha-de-compilers--elixir-transcompiler:0.2.0
```

### Clone
```sh
git clone git@github.com:rwillians/rinha-de-compilers--elixir-transcompiler.git rwillians
```

```sh
cd rwillians
```

### Build
```sh
docker build -t rwillians .
```

### Run a program once
```sh
docker run \
  --mount type=bind,source="/absolute/path/to/source.rinha",target="/var/rinha/source.rinha" \
  rwillians

# eg:
# docker run \
#   --mount type=bind,source="/Users/rwillians/Projects/oss/rinha-de-compilers--elixir-transpiler/.rinha/files/fib.rinha",target="/var/rinha/source.rinha" \
#   rwillians
```

### Run a program multiple times (for benchmarking):
```sh
docker run \
  --mount type=bind,source="/absolute/path/to/source.rinha",target="/var/rinha/source.rinha" \
  rwillians /var/rinha/source.rinha 10
  #                                 ^ compile once, run the program 10 times
```

```sh
time docker run \
  --mount type=bind,source="/absolute/path/to/source.rinha",target="/var/rinha/source.rinha" \
  rwillians /var/rinha/source.rinha 1000000
  #                                 ^ compile once, run the program 1Mi times
```
