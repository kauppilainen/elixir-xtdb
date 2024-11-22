defmodule ElixirXtdbWeb.LightLive do
  use ElixirXtdbWeb, :live_view

  def mount(_params, _session, socket) do
    # Fetch XTDB data
    # TODO fetch XTDB history here
    transactions = XTDB.get_transaction_history()

    form_state = %{"slider" => length(transactions)}
    socket = assign(socket, form: to_form(form_state))
    socket = assign(socket, transactions: transactions)

    # TODO fetch trades here
    socket =
      assign(socket,
        trades: [
          %{:_id => 1, :value => 10},
          %{:_id => 2, :value => 20},
          %{:_id => 3, :value => 30},
          %{:_id => 4, :value => 40},
          %{:_id => 5, :value => 50}
        ]
      )

    {:ok, socket}
  end

  def render(assigns) do
    # HEEx = HTML + EEx
    # phx-click is a binding

    ~H"""
    <h1 class="text-xl font-semibold">Timeline</h1>
    <p>
      <%= hd(
        Enum.at(
          assigns.transactions,
          case Map.fetch(@form, :slider) do
            {:ok, idx} -> idx
            :error -> length(assigns.transactions) - 1
          end
        )
      ) %>
    </p>
    <div class="grid gap-4">
      <div class="pb-4">
        <.form for={@form} phx-change="update_rate">
          <.input
            type="range"
            name="slider"
            min="1"
            max={"#{length(@transactions)}"}
            value={"#{Map.fetch(@form, :slider)}"}
          />
          <div class="pt-2">
            <button class="bg-blue-500 hover:bg-blue-700 text-sm text-white font-semibold py-1 px-2 rounded">
              Fetch state
            </button>
          </div>
        </.form>
      </div>

      <div>
        <h2 class="text-xl font-semibold">Trades</h2>
        <%= for %{_id: id, value: value} <- @trades do %>
          <div>
            <span><%= id %>: <%= value %></span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("update_rate", %{"slider" => v}, socket) do
    form = to_form(%{"slider" => v})
    {:noreply, assign(socket, form: form)}
  end
end
