defmodule XTDB do
  def connect_and_query do
    {:ok, pid} =
      Postgrex.start_link(
        hostname: "localhost",
        port: 5432,
        database: "xtdb"
      )

    insert_query = """
    INSERT INTO trades (_id, price) VALUES (1, 100);
    """

    update_query = """
    UPDATE trades SET price = 150 WHERE _id = 1;
    """

    select_query = "SELECT _id, price, _valid_from FROM trades"

    Postgrex.query(pid, insert_query, [])
    Postgrex.query(pid, update_query, [])

    {:ok, %Postgrex.Result{rows: rows}} = Postgrex.query(pid, select_query, [])

    rows
  end

  def populate do
    {:ok, pid} =
      Postgrex.start_link(
        hostname: "localhost",
        port: 5432,
        database: "xtdb"
      )

    trades = Enum.map(1..100, fn id -> "(#{id}, #{id * 2})" end)

    insert_query =
      "INSERT INTO trades (_id, price) VALUES " <>
        Enum.join(
          Enum.intersperse(
            trades,
            ","
          )
        )

    select_query = "SELECT * FROM trades"
    IO.puts(insert_query)
    Postgrex.query(pid, insert_query, [])
    {:ok, %Postgrex.Result{rows: rows}} = Postgrex.query(pid, select_query, [])

    IO.puts("Trades:")
    Enum.each(rows, fn [id, price] -> IO.puts("  * #{id}: #{price}") end)
  end
end
