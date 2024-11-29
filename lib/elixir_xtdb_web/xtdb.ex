defmodule XTDB do
  @db_opts [
    hostname: "localhost",
    port: 5432,
    database: "xtdb"
  ]

  def get_trades() do
    with {:ok, pid} <- Postgrex.start_link(@db_opts),
         {:ok, %Postgrex.Result{rows: rows}} <-
           Postgrex.query(pid, "SELECT _id, price FROM trades", []) do
      Enum.map(rows, fn [id, price] -> %{_id: id, value: price} end)
    end
  end

  def get_trades(timestamp) do
    with {:ok, pid} <- Postgrex.start_link(@db_opts),
         {:ok, %Postgrex.Result{rows: rows}} <-
           Postgrex.query(pid, "SELECT _id, price FROM trades FOR VALID_TIME AS OF TIMESTAMP '#{timestamp}'", []) do
      Enum.map(rows, fn [id, price] -> %{_id: id, value: price} end)
    end
  end

  def get_transaction_history do
    with {:ok, pid} <- Postgrex.start_link(@db_opts),
         {:ok, %Postgrex.Result{rows: rows}} <-
           Postgrex.query(pid, "SELECT system_time FROM xt.txs ORDER BY system_time ASC", []) do
      rows
    end
  end

  def populate do
    {:ok, pid} = Postgrex.start_link(@db_opts)

    trades = Enum.map(1..100, fn id -> {id, id * 2} end)

    Enum.each(trades, fn {id, price} ->
      {:ok, _} = Postgrex.query(pid, "BEGIN", [])
      {:ok, _} =
        Postgrex.query(pid, "INSERT INTO trades (_id, price) VALUES (#{id}, #{price})", [])
      {:ok, _} = Postgrex.query(pid, "COMMIT", [])
    end)

    select_query = "SELECT * FROM trades"
    {:ok, %Postgrex.Result{rows: rows}} = Postgrex.query(pid, select_query, [])

    rows
  end
end
