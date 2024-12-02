defmodule ElixirXtdbWeb.Trades do
  use ElixirXtdbWeb, :live_view

  def mount(_params, _session, socket) do
    transactions = XTDB.get_transaction_history()
    index = length(transactions) - 1

    socket =
      socket
      |> assign(:show_edit_modal, false)
      |> assign(:editing_trade, nil)
      |> assign(:index, index)
      |> assign(:current_timestamp, get_current_timestamp(transactions, index))
      |> assign(:transactions, transactions)
      |> assign(:trades, XTDB.get_trades())
      |> assign(:form, to_form(%{"slider" => index}))

    {:ok, socket}
  end

  attr :trade, :map, required: true

  def trade(assigns) do
    ~H"""
    <div
      class="flex items-center gap-2 cursor-pointer"
      phx-click="edit_trade"
      phx-value-id={@trade._id}
    >
      <span class="font-semibold"><%= @trade._id %>:</span>
      <code><%= @trade.symbol %></code>
      | <code><%= @trade.volume %></code>
      | <code><%= @trade.valid_from %></code>
    </div>
    """
  end

  attr :trades, :list, required: true

  def trades_list(assigns) do
    ~H"""
    <div>
      <h2 class="text-xl font-semibold">Trades</h2>
      <div class="space-y-2">
        <.trade :for={trade <- Enum.sort_by(@trades, & &1._id)} trade={trade} />
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-xl font-semibold">Timeline</h1>
      <.modal :if={@show_edit_modal} id="edit-trade-modal" show on_cancel={JS.push("close_modal")}>
        <.form for={%{}} phx-submit="save_trade">
          <div class="space-y-4">
            <input type="hidden" name="trade_id" value={@editing_trade._id} />
            <.input type="text" label="Symbol" name="symbol" value={@editing_trade.symbol} />
            <.input type="number" label="Volume" name="volume" value={@editing_trade.volume} />
            <.input
              type="datetime-local"
              label="Valid From"
              name="valid_from"
              value={@editing_trade.valid_from}
            />
            <.button type="submit">Save Changes</.button>
          </div>
        </.form>
      </.modal>
      <div class="text-sm text-gray-600">
        Trades as of: <span class="font-bold"><%= @current_timestamp %></span>

        <.form for={@form} phx-change="update_as_of_timestamp" class="space-y-4">
          <.input type="range" name="slider" min="1" max={length(@transactions)} value={@index + 1} />
          <.button type="button" phx-click="fetch_state">
            Fetch state
          </.button>
          <.button :if={Enum.empty?(@trades)} type="button" phx-click="populate">
            Populate trades
          </.button>
        </.form>
      </div>

      <.trades_list trades={@trades} />
    </div>
    """
  end

  def handle_event("update_as_of_timestamp", %{"slider" => value}, socket) do
    index = String.to_integer(value) - 1
    transactions = socket.assigns.transactions

    socket =
      socket
      |> assign(:form, to_form(%{"slider" => value}))
      |> assign(:index, index)
      |> assign(:current_timestamp, get_current_timestamp(transactions, index))

    {:noreply, socket}
  end

  def handle_event("fetch_state", _params, socket) do
    IO.puts(socket.assigns.current_timestamp)
    trades = XTDB.get_trades(socket.assigns.current_timestamp)
    IO.inspect(trades, label: "Current trades")

    socket = assign(socket, :trades, trades)

    {:noreply, socket}
  end

  def handle_event("populate", _params, socket) do
    XTDB.populate()

    # Refresh the trades list after populating
    socket = assign(socket, :trades, XTDB.get_trades())
    {:noreply, socket}
  end

  def handle_event("edit_trade", %{"id" => id}, socket) do
    trade = Enum.find(socket.assigns.trades, &(&1._id == String.to_integer(id)))

    socket =
      socket
      |> assign(:editing_trade, trade)
      |> assign(:show_edit_modal, true)

    {:noreply, socket}
  end

  def handle_event(
        "save_trade",
        %{"trade_id" => id, "symbol" => symbol, "volume" => volume, "valid_from" => valid_from},
        socket
      ) do
    XTDB.update_trade(
      String.to_integer(id),
      symbol,
      String.to_integer(volume),
      to_iso8601_string(valid_from)
    )

    socket =
      socket
      |> assign(:trades, XTDB.get_trades())
      |> assign(:show_edit_modal, false)
      |> assign(:editing_trade, nil)

    {:noreply, socket}
  end

  def handle_event("close_modal", _params, socket) do
    socket = assign(socket, :show_edit_modal, false)
    {:noreply, socket}
  end

  defp get_current_timestamp(transactions, index) when length(transactions) > 0 do
    case Enum.at(transactions, index) do
      [timestamp | _] when not is_nil(timestamp) ->
        DateTime.to_iso8601(timestamp)

      _ ->
        nil
    end
  end

  defp get_current_timestamp(_, _), do: nil

  def to_iso8601_string(datetime_string) do
    {:ok, naive_dt} = NaiveDateTime.from_iso8601(datetime_string <> ":00.000")
    {:ok, dt} = DateTime.from_naive(naive_dt, "Etc/UTC")
    DateTime.to_iso8601(dt)
  end
end
