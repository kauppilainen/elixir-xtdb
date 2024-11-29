defmodule ElixirXtdbWeb.LightLive do
  use ElixirXtdbWeb, :live_view

  def mount(_params, _session, socket) do
    transactions = XTDB.get_transaction_history()
    index = length(transactions) - 1
    socket =
      socket
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
    <div class="flex items-center gap-2">
      <span class="font-medium"><%= @trade._id %>:</span>
      <span><%= @trade.value %></span>
      <span><%= @trade.valid_from %></span>
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

      <div class="text-sm text-gray-600">
        Trades as of: <span class="font-bold"><%= @current_timestamp %></span>

      <.form for={@form} phx-change="update_as_of_timestamp" class="space-y-4">
        <.input type="range" name="slider" min="1" max={length(@transactions)} value={@index + 1} />
        <.button type="button" phx-click="fetch_state">
          Fetch state
        </.button>
        <.button type="button" phx-click="populate">
          Populate Database
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

  defp get_current_timestamp(transactions, index) when length(transactions) > 0 do
    case Enum.at(transactions, index) do
      [timestamp | _] when not is_nil(timestamp) ->
        DateTime.to_iso8601(timestamp)
      _ ->
        nil
    end
  end

  defp get_current_timestamp(_, _), do: nil
end
