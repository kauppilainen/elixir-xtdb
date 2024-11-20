defmodule ElixirXtdb.Repo do
  use Ecto.Repo,
    otp_app: :elixir_xtdb,
    adapter: Ecto.Adapters.Postgres
end
