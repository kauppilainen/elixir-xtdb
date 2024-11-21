defmodule ElixirXtdbWeb.LightLive do
  use ElixirXtdbWeb, :live_view

  # mount
  def mount(_params, _session, socket) do
    # Fetch XTDB data
    socket = assign(socket, brightness: 10)

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
    <h1>Front Porch light</h1>

    <div class="slidecontainer">
      <form phx-change="update_date">
        <input type="range" min="1" max={"#{length(@trades)}"} value="1" id="trades-timeline" />
      </form>
    </div>
    """
  end

  # handle_events
  def handle_event("update_date", payload, socket) do
    # IO.puts(payload)
    {:noreply, assign(socket, brightness: 0)}
  end
end
