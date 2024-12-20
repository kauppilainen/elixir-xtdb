# Elixir+XTDB

This is an example project for Phoenix and XTDB. Once up and running head over to [localhost:4000/trades](localhost:4000/trades) to populate, view and update trades as well as play around with XT's bitemporal indices. 
This project is based on the [Late Trade adjustments](https://docs.xtdb.com/tutorials/financial-usecase/late-trade.html) example at [docs.xtdb.com](https://docs.xtdb.com)

## Run locally

To start your Phoenix server:

* Start Phoenix Postgres and XTDB instance 

  ```sh
  # Phoenix internal DB
  docker run -it --name phoenix-liveview --replace --pull=always -p 5433:5432 -e POSTGRES_PASSWORD=postgres -d postgres

  # XTDB
  docker run -it --rm --name phoenix-liveview-xtdb --pull=always -p 6543:3000 -p 5432:5432 ghcr.io/xtdb/xtdb
  ```

* Run `mix setup` to install and setup dependencies
* Run `mix ecto.create` to setup Phoenix DB
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

You can now visit [`localhost:4000`](http://localhost:4000) from your browser.

### Manually query XTDB using `psql`

``` sh
# Connect
psql -h localhost -p 5432
```


### Queries

``` sh
# All trades up until now
SELECT *, _valid_from, _system_from FROM trades; 
# All trades up until '2024-01-15 20:00:00.000Z'
SELECT *, _valid_from, _system_from FROM trades FOR VALID_TIME AS OF TIMESTAMP '2024-01-15 20:00:00.000Z';
```

