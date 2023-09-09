<div align="center">
  <a href="https://github.com/aripiprazole/rinha-de-compiler" alt="Link para o repositório da Rinha de Compiladores" target="_blank">
    <img src="https://raw.githubusercontent.com/aripiprazole/rinha-de-compiler/main/img/banner.png" alt="Logo da Rinha de Compilers">
  </a>
</div>

---

A idea aqui é fazer um transpilador em elixir o qual, ao compilar o projeto em Elixir, carrega a AST genérica da rinha e a compila como um módulo Elixir.

Caso a AST genérica represente (ou contenha) código proceduram (um script, código executado fora de uma função), tal árvore sintática será transpilada dentro de uma função `main/0` dentro do módulo para onde a AST está sendo transpilada e compilada.

Dessaforma, não há interpretação da AST durante runtime. O Transpiling acontece em compile-time, logo, a performance em runtime é a mesma comparada ao mesmo código escrito diretamente em Elixir.

> **Warning**
> A implementação do transpiler não é completa. Ela contempla apenas o mínimo necessário para rodar os cenários da rinha.


## Uso

É necessário criar um módulo em Elixir dentro do qual a um arquivo de AST genérica (aqueles em JSON) será transpilado. Não é permitido transpilar mais de 1 arquivo de AST por módulo.

```elixir
defmodule Rinha.Fib do
  use Transpiler, source: {:ast, json: ".rinha/files/fib.json"}
end
```

As funções definidas no AST genérica serão compiladas como funções públicas dentro do módulo. Então, supondo que na AST genérica há a definição de uma função chamada `fib/1`, tal função poderá ser invocada como `Rinha.Fib.fin/1`, onde `Rinha.Fib` é o nome do módulo dentro do qual a AST será transpilada e compilada.


## Como rodar

> **Note**
> Pressuponho que você tenha `asdf-vm` instalado (pois  se não tem, deveria viu 👀 -- é tipo um nvm, mas pra tudo quanto é linguagem e ferramentas).

1.  Clona o repo (uso o repo da rinha como submodule):

    ```sh
    git clone --recursive git@github.com:rwillians/rinha-de-compiladores.git
    ```

2.  Instala Elixir e Erlang nas versões definidas no arquivo `.tool-versions`:

    ```sh
    asdf install
    ```

3.  Instala as dependências:

    ```sh
    mix deps.get
    ```

4.  Sobe o REPL:

    ```sh
    iex -S mix
    ```

5.  Roda o programa:

    ```elixir
    Rinha.Fib.main()
    ```

    Se preferir, pode rodar `fib` diretamente:

    ```elixir
    Rinha.Fib.fib(15)
    ```


## Sobre mim

Pago meus boletos fazendo programa faz mais de 10 anos. Manjo pouquíssimo de compiladores, transpiladores, parsers, lexers, grammar e etc mas tamo aí aprendendo. Sou especialista em fazer carinho em gatinhos 🐈, mestre em diminuir tempo de vida de plantas -- até cactos --, arranho uns acordes no violão e às vezes até arrisco cantar, eterno pianista aprediz -- sério, aprendiz mesmo, sei quase nada kkkkry --, faixa branca em Ninjutso -- sim, isso existe, não é só coisa de Naruto -- e tô sempre com One Piece em dia.

|      Onde | Link                                                 |
|----------:|:-----------------------------------------------------|
| 𝕏 Twitter | [@rwillians_](https://twitter.com/rwillians_)        |
|  LinkedIn | [@rwillians](https://www.linkedin.com/in/rwillians/) |
|    GitHub | [@rwillians](https://github.com/rwillians)           |
|    Resume | [rwillians.com](https://rwillians.com/resume)        |
