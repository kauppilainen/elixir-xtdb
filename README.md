# ElixirXtdb

To start your Phoenix server:

  * Start XTDB and Phoenix Postgres instance 

    ```sh
    # Phoenix internal DB
    docker run -it --replace --pull=always --name phoenix-liveview -p 5433:5432 -e POSTGRES_PASSWORD=postgres -d postgres
    # XTDB
    docker run -it --name phoenix-liveview-xtdb --pull=always -p 6543:3000 -p 5432:5432 ghcr.io/xtdb/xtdb
    ```

  * Run `mix setup` to install and setup dependencies
  * Run `mix ecto.create` to setup Phoenix DB
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
