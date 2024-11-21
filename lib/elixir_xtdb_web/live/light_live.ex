defmodule ElixirXtdbWeb.LightLive do
  use ElixirXtdbWeb, :live_view

  # mount
  def mount(_params, _session, socket) do
    # Fetch XTDB data
    socket = assign(socket, brightness: 10)
    socket = assign(socket, trades: [%{:_id => 1, :value => 10},
                                     %{:_id => 2, :value => 20}
                                    ])
    {:ok, socket}
  end

  # render
  def render(assigns) do
    # HEEx = HTML + EEx
    # phx-click is a binding
    ~H"""
    <h1>Front Porch light</h1>

    <div class="slidecontainer">
      <input type="range" min="1" max={"#{length(@trades)}"} value="1" id="trades-timeline">
    </div>

    <div class="w-full my-4">
      <div style={"width: #{@brightness}%; background: green"}>
        <%= assigns.brightness %>%
      </div>
    </div>
    <div class="w-full flex justify-around">
      <button phx-click="off">Light off</button>
      <button phx-click="decr">-</button>
      <button phx-click="inc">+</button>
      <button phx-click="on">Light on</button>
      </div>
    """
  end

  # handle_events
  def handle_event("on", _payload, socket) do
    {:noreply, assign(socket, brightness: 100)}
  end

  def handle_event("inc", _payload, socket) do
    socket = update(socket, :brightness, &(&1 + 10))
    {:noreply, socket}
  end

  def handle_event("decr", _payload, socket) do
    socket = update(socket, :brightness, &(&1 - 10))
    {:noreply, socket}
  end

  def handle_event("off", _payload, socket) do
    {:noreply, assign(socket, brightness: 0)}
  end

end
