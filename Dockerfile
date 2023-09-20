FROM elixir:1.15.4-alpine AS build

WORKDIR /app
ENV MIX_ENV=dev

RUN apk add --no-cache git ncurses libstdc++ libgcc && \
    mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --no-archives-check --only=dev
RUN mix deps.compile

COPY lib/ lib/
RUN rm -rf lib/rinha/ lib/rinha.ex \
    && mix compile

COPY play.exs play.exs

#

FROM elixir:1.15.4-alpine AS dev

WORKDIR /app
ENV MIX_ENV=dev

RUN mix local.hex --force && \
    mix local.rebar --force

COPY --from=build /app/ /app/

VOLUME [ "/data" ]

STOPSIGNAL SIGINT
ENTRYPOINT [ "mix" ]
