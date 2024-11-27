defmodule ElixirXtdbWeb.LightLive do
  use ElixirXtdbWeb, :live_view

  def mount(_params, _session, socket) do
    transactions = XTDB.get_transaction_history()
    index = length(transactions)

    socket =
      socket
      |> assign(:transactions, transactions)
      |> assign(:form, to_form(%{"slider" => index}))
      |> assign(:index, index)
      |> assign(:current_timestamp, get_current_timestamp(transactions, index))
      |> assign(:trades, XTDB.get_trades())

    {:ok, socket}
  end

  attr :trades, :list, required: true

  def trades_list(assigns) do
    ~H"""
    <div>
      <h2 class="text-xl font-semibold">Trades</h2>
      <div class="space-y-2">
        <.trade :for={trade <- @trades} trade={trade} />
      </div>
    </div>
    """
  end

  attr :trade, :map, required: true

  def trade(assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <span class="font-medium"><%= @trade._id %>:</span>
      <span><%= @trade.value %></span>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-6">
      <h1 class="text-xl font-semibold">Timeline</h1>

      <div class="text-sm text-gray-600">
        Current timestamp: <%= @current_timestamp %>
      </div>

      <.form for={@form} phx-change="update_rate" class="space-y-4">
        <.input type="range" name="slider" min="1" max={length(@transactions)} value={@index} />

        <.button phx-click="fetch_state" class="bg-blue-500 hover:bg-blue-700">
          Fetch state
        </.button>
      </.form>

      <.trades_list trades={@trades} />
    </div>
    """
  end

  def handle_event("update_rate", %{"slider" => v}, socket) do
    form = to_form(%{"slider" => v})
    socket = assign(socket, form: form)

    transactions = XTDB.get_transaction_history()

    socket = assign(socket, index: v - 1)
    socket = assign(socket, current_timestamp: hd(Enum.at(transactions, v - 1)))
    {:noreply, socket}
  end

  # Add this function to ElixirXtdbWeb.LightLive
  defp get_current_timestamp(transactions, index) when length(transactions) > 0 do
    transactions
    |> Enum.at(index - 1)
    |> hd()
  end
  defp get_current_timestamp(_, _), do: nil
end
