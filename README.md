# ElixirXtdb

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Run `mix ecto.create` to setup Phoenix DB
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## DB's

```sh
# Phoenix internal DB
docker run -it --replace --pull=always --name phoenix-liveview -p 5433:5432 -e POSTGRES_PASSWORD=postgres -d postgres
# XTDB
docker run -it --name phoenix-liveview-xtdb --pull=always -p 6543:3000 -p 5432:5432 ghcr.io/xtdb/xtdb
```

### Config

Setup LiveView PostgresQL config in config/dev.exs 

```elixir
config :elixir_xtdb, ElixirXtdb.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5433,
  database: "elixir_xtdb_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```


Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
