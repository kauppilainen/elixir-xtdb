defmodule ElixirXtdbWeb.LightLive do
  use ElixirXtdbWeb, :live_view

  # mount
  def mount(_params, _session, socket) do
    # Fetch XTDB data
    socket = assign(socket, form: to_form(%{"slider" => 1}))

    # TODO fetch XTDB history here
    transactions = XTDB.connect_and_query()

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

  # render
  def render(assigns) do
    # HEEx = HTML + EEx
    # phx-click is a binding
    ~H"""
    <h1 class="text-xl font-semibold">Timeline</h1>

    <div class="grid gap-4">
      <div class="pb-4">
        <.form for={@form} phx-change="update_rate">
          <.input
            type="range"
            name="slider"
            min="1"
            max={"#{length(@trades)}"}
            value={"#{Map.fetch(@form, :slider)}"}
            id="trades-timeline"
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
        <%= for [id, price] <- @transactions do %>
          <div>
            <span><%= id %>: <%= price %></span>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # handle_events
  def handle_event("update_rate", %{"slider" => v}, socket) do
    form = to_form(%{"slider" => v})
    {:noreply, assign(socket, form: form)}
  end
end
