defmodule ElixirXtdbWeb.Trades do
  use ElixirXtdbWeb, :live_view

  def mount(_params, _session, socket) do
    transactions = XTDB.get_transaction_history()
    IO.inspect(transactions, label: "transactions")
    system_from_index = length(transactions) - 1

    all_trades = XTDB.get_trades()
    all_trade_dates = get_unique_trade_dates(all_trades)
    valid_from_index = length(all_trade_dates) - 1

    socket =
      socket
      |> close_modal()
      |> update_system_time_slider_state(system_from_index, transactions)
      |> update_valid_time_slider_state(valid_from_index, all_trade_dates)
      |> assign(:transactions, transactions)
      |> assign(:trades, all_trades)

    {:ok, socket}
  end

  def close_modal(socket) do
    socket
    |> assign(:show_edit_modal, false)
    |> assign(:editing_trade, nil)
  end

  def open_modal(socket, trade) do
    socket
    |> assign(:show_edit_modal, true)
    |> assign(:editing_trade, trade)
  end


  def update_system_time_slider_state(socket, index, transactions) do
    socket
    |> assign(:system_from_index, index)
    |> assign(:system_from_timestamp, Enum.at(transactions, index))
    |> assign(:system_from_form, to_form(%{"slider" => index + 1}))
    |> assign(:transactions, transactions)
  end

  def update_valid_time_slider_state(socket, index, tradeDates) do
    socket
    |> assign(:valid_from_index, index)
    |> assign(:valid_from_timestamp, Enum.at(tradeDates, index))
    |> assign(:valid_from_form, to_form(%{"slider" => index + 1}))
    |> assign(:all_trade_dates, tradeDates)
  end

  def get_unique_trade_dates(trades) do
    trades |> Enum.map(& &1.valid_from) |> Enum.uniq() |> Enum.sort()
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

  def slider(assigns) do
    ~H"""
    <div class="text-sm text-gray-600">
      Trades as of <code class="font-bold"><%= @type %></code>:
      <span class="font-bold"><%= @current_timestamp %></span>
      <.form for={@form} phx-change={@event} class="space-y-4">
        <.input type="range" name="slider" min="1" max={@max} value={@value} phx-debounce="500" />
      </.form>
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

      <.slider
        type="system time"
        event="update_system_from"
        form={@system_from_form}
        current_timestamp={@system_from_timestamp}
        max={length(@transactions)}
        value={@system_from_index + 1}
      />

      <.slider
        type="valid time"
        event="update_valid_from"
        form={@valid_from_form}
        current_timestamp={@valid_from_timestamp}
        max={length(@all_trade_dates)}
        value={@valid_from_index + 1}
      />

      <.button :if={Enum.empty?(@trades)} type="button" phx-click="populate">
        Populate trades
      </.button>

      <.trades_list trades={@trades} />
    </div>
    """
  end

  def handle_event("update_system_from", %{"slider" => value}, socket) do
    system_from_index = String.to_integer(value) - 1
    system_from_timestamp = Enum.at(socket.assigns.transactions, system_from_index)

    valid_from_index = socket.assigns.valid_from_index

    valid_from_timestamp =
      Enum.at(socket.assigns.all_trade_dates, valid_from_index)

    trades = XTDB.get_trades(valid_from_timestamp, system_from_timestamp)

    socket =
      socket
      |> update_system_time_slider_state(system_from_index,  socket.assigns.transactions)
      |> assign(:trades, trades)

    {:noreply, socket}
  end

  def handle_event("update_valid_from", %{"slider" => value}, socket) do
    all_trades = XTDB.get_trades()
    all_trade_dates = get_unique_trade_dates(all_trades)
    valid_from_index = String.to_integer(value) - 1

    valid_from_timestamp =
      Enum.at(all_trade_dates, valid_from_index)

    system_from_index = socket.assigns.system_from_index
    system_from_timestamp = Enum.at(socket.assigns.transactions, system_from_index)

    trades = XTDB.get_trades(valid_from_timestamp, system_from_timestamp)

    socket =
      socket
      |> update_valid_time_slider_state(valid_from_index, all_trade_dates)
      |> assign(:trades, trades)

    {:noreply, socket}
  end

  def handle_event("populate", _params, socket) do
    all_trades = XTDB.populate()
    all_trade_dates = get_unique_trade_dates(all_trades)
    transactions = XTDB.get_transaction_history()

    socket =
      socket
      |> update_system_time_slider_state(length(transactions) - 1, transactions)
      |> update_valid_time_slider_state(length(all_trade_dates) - 1, all_trade_dates)
      |> assign(:transactions, transactions)
      |> assign(:trades, all_trades)

    {:noreply, socket}
  end

  def handle_event("edit_trade", %{"id" => id}, socket) do
    trade = Enum.find(socket.assigns.trades, &(&1._id == String.to_integer(id)))
    socket = open_modal(socket, trade)

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

    all_trades = XTDB.get_trades()
    all_trade_dates = get_unique_trade_dates(all_trades)
    transactions = XTDB.get_transaction_history()

    socket =
      socket
      |> close_modal()
      |> assign(:transactions, transactions)
      |> assign(:all_trade_dates, all_trade_dates)

    {:noreply, socket}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, close_modal(socket)}
  end

  def to_iso8601_string(datetime_string) do
    {:ok, naive_dt} = NaiveDateTime.from_iso8601(datetime_string <> ":00.000")
    {:ok, dt} = DateTime.from_naive(naive_dt, "Etc/UTC")
    DateTime.to_iso8601(dt)
  end
end
