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

  def populate do
    {:ok, pid} = Postgrex.start_link(@db_opts)

    trades = [
      {1, "BTC", 100, "2024-01-01 00:00:00"},
      {2, "ETH", 250, "2024-01-01 00:00:00"},
      {3, "SOL", 500, "2024-01-01 00:00:00"},
      {4, "DOT", 150, "2024-01-01 00:00:00"},
      {5, "AVAX", 300, "2024-01-01 00:00:00"},
      {6, "MATIC", 450, "2024-01-01 00:00:00"},
      {7, "LINK", 200, "2024-01-01 00:00:00"},
      {8, "ADA", 350, "2024-01-01 00:00:00"},
      {9, "XRP", 600, "2024-01-01 00:00:00"},
      {10, "ATOM", 175, "2024-01-01 00:00:00"}
    ]

    Enum.each(trades, fn {id, symbol, volume, valid_from} ->
      {:ok, _} = Postgrex.query(pid, "BEGIN", [])

      {:ok, _} =
        Postgrex.query(
          pid,
          "INSERT INTO trades (_id, symbol, volume, _valid_from) VALUES (#{id}, '#{symbol}', #{volume}, TIMESTAMP '#{valid_from}')",
          []
        )

      {:ok, _} = Postgrex.query(pid, "COMMIT", [])
    end)

    select_query = "SELECT * FROM trades"
    {:ok, %Postgrex.Result{rows: rows}} = Postgrex.query(pid, select_query, [])

    rows
  end
end
