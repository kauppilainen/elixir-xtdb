defmodule XTDB do
  @db_opts [
    hostname: "localhost",
    port: 5432,
    database: "xtdb"
  ]
  def get_trades() do
    with {:ok, pid} <- Postgrex.start_link(@db_opts),
         {:ok, %Postgrex.Result{rows: rows}} <-
           Postgrex.query(pid, "SELECT _id, symbol, volume, _valid_from FROM trades", []) do
      Enum.map(rows, fn [id, symbol, volume, valid_from] ->
        %{_id: id, symbol: symbol, volume: volume, valid_from: valid_from}
      end)
    end
  end

  def get_trades(timestamp) do
    with {:ok, pid} <- Postgrex.start_link(@db_opts),
         {:ok, %Postgrex.Result{rows: rows}} <-
           Postgrex.query(
             pid,
             "SELECT _id, symbol, volume, _valid_from FROM trades FOR VALID_TIME AS OF TIMESTAMP '#{timestamp}'",
             []
           ) do
      Enum.map(rows, fn [id, symbol, volume, valid_from] ->
        %{_id: id, symbol: symbol, volume: volume, valid_from: valid_from}
      end)
    end
  end

  def update_trade(id, symbol, volume, valid_from) do
    with {:ok, pid} <- Postgrex.start_link(@db_opts) do
      {:ok, _} =
        Postgrex.query(
          pid,
          "INSERT INTO trades (_id, symbol, volume, _valid_from) VALUES (#{id}, '#{symbol}', #{volume}, TIMESTAMP '#{valid_from}')",
          []
        )
    end
  end

  def get_transaction_history do
    with {:ok, pid} <- Postgrex.start_link(@db_opts),
         {:ok, %Postgrex.Result{rows: rows}} <-
           Postgrex.query(pid, "SELECT system_time FROM xt.txs ORDER BY system_time ASC", []) do
      rows
    end
  end

  def insert_trades_at(pid, trades, system_time) do
    Enum.each(trades, fn {id, symbol, volume, valid_from} ->
      {:ok, _} = Postgrex.query(pid, "START TRANSACTION READ WRITE, AT SYSTEM_TIME TIMESTAMP '#{system_time}'", [])

      {:ok, _} =
        Postgrex.query(
          pid,
          "INSERT INTO trades (_id, symbol, volume, _valid_from) VALUES (#{id}, '#{symbol}', #{volume}, TIMESTAMP '#{valid_from}')",
          []
        )

      {:ok, _} = Postgrex.query(pid, "COMMIT", [])
    end)
  end

  def populate do
    {:ok, pid} = Postgrex.start_link(@db_opts)

    # Pre close trades 2024-01-15 16:59:00
    insert_trades_at(
      pid,
      [
        {1, "XAU:CUR", 150, "2024-01-15 10:00:00"},
        {2, "NG1:COM", 430, "2024-01-15 11:15:00"},
        {3, "XAU:CUR", 200, "2024-01-15 12:05:00"}
      ],
      "2024-01-15 16:59:00"
    )

    # Post close trades 2024-01-15 19:00:00
    insert_trades_at(pid, [{4, "W1:COM", 320, "2024-01-15 16:50:00"}], "2024-01-15 19:00:00")

    # Day after trades 2024-01-16 16:59:00
    insert_trades_at(
      pid,
      [
        {5, "W1:COM", 100, "2024-01-16 12:10:00"},
        {6, "W1:COM", 120, "2024-01-16 14:55:00"}
      ],
      "2024-01-16 16:59:00"
    )

    select_query = "SELECT * FROM trades"
    {:ok, %Postgrex.Result{rows: rows}} = Postgrex.query(pid, select_query, [])

    rows
  end
end
