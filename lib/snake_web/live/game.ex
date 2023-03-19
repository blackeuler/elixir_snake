defmodule SnakeWeb.GameLive do
  use SnakeWeb, :live_view

  @tick_rate 30

  alias Snake.Game.Server
  alias Snake.Game

            #<rect width={@game_model.width} height={@game_model.height} x={0 } y={0 } fill="black" />
  def render(assigns) do
    ~H"""
    <%= if not is_nil(@current_player) and not is_nil(@game_model) do %>
    <script>
      // Add this script to send browser window dimensions to the server
      window.addEventListener('resize', () => {
        let width = window.innerWidth;
        let height = window.innerHeight;
        window.Phoenix.LiveView.pushEvent(window, 'send_dimensions', {width, height});
      });
    </script>

      <svg   phx-hook="move" id="game"
      viewBox={Game.to_svg_box(@game_model,@current_player,@window_width,@window_height)}
      xmlns="http://www.w3.org/2000/svg">
      <defs>
    <pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse">
      <path d="M 20 0 L 0 0 0 20" fill="none" stroke="gray" stroke-width="0.5"/>
    </pattern>
    </defs>
    <rect x="0" y="0" width="100%" height="100%" fill="#2d2d2d" />
    <rect x="25" y="25" width={@game_model.width} height={@game_model.height} fill="url(#grid)" />
            <!-- Simple rectangle -->
            <%= for snake <- @game_snakes do %>
                <.snakec snake={snake} />
            <% end %>
            <%= for food <- Game.all_food(@game_model) do %>
                <.foodc food={food} />
            <% end %>
       </svg>
    <% else %>
    <.form :let={f} for={@player_changeset}  phx-submit="save">
    <%= label f, :name %>
    <%= text_input f, :name %>
    <%= error_tag f, :name %>


    <%= submit "Save" %>
    </.form>
    <% end %>
    """
  end

  def mount(_session, _params, socket) do
    {:ok,
     socket
     |> assign_window_dimensions()
     |> assign_game_model()
     |> assign_snakes
     |> assign_player_changeset()
     |> assign_players()}
  end

  def assign_game_model(socket) do
    assign(socket, game_model: nil)
  end

  def assign_window_dimensions(socket) do
    assign(socket, window_height: 800)
    |> assign(window_width: 800)
  end

  def assign_snakes(%{assigns: %{game_model: nil}} = socket) do
    socket
  end

  def assign_snakes(%{assigns: %{game_model: game_model}} = socket) do
    assign(socket, game_snakes: Game.all_snakes(game_model))
  end

  def assign_players(socket) do
    assign(socket, players: [])
  end

  def assign_player_changeset(socket) do
    assign(socket, player_changeset: Game.change_player())
    |> assign(current_player: nil)
  end

  def handle_event(
        "window_size",
        %{"width" => x, "height" => y},
        socket
      ) do
    {:noreply, assign(socket, window_height: y) |> assign(window_width: x)}
  end

  def handle_event(
        "angle_change",
        %{"x" => x, "y" => y},
        %{assigns: %{current_player: cp}} = socket
      ) do
    Server.change_snake_angle(GameServer, cp, {x, y})

    {:noreply, socket}
  end

  def handle_event(
        "save",
        %{"player" => %{"name" => name}},
        socket
      ) do
    {cp, gm} = Server.join(GameServer, name)

    schedule_update()

    {:noreply,
     socket
     |> assign(:game_model, gm)
     |> assign_snakes()
     |> assign(:current_player, cp)}
  end

  def handle_info(%{event: "update"}, %{assigns: %{game_model: gm}} = socket) do
    {:noreply, assign(socket, game_model: Game.update(gm, 10))}
  end

  def handle_info(%{event: "player_joined", payload: %{new_player: snake}}, socket) do
    {:noreply,
     socket
     |> assign(:game_model, Game.add_snake(socket.assigns.game_model, snake))
     |> assign(:players, [snake | socket.assigns.players])}
  end

  defp schedule_update() do
    # In 30 seconds
    Process.send_after(self(), :update, @tick_rate)
  end

  def handle_info(:update, socket) do
    schedule_update()

    {:noreply,
     assign(socket, game_model: Server.get_game_state(GameServer))
     |> assign_snakes}
  end

  attr :x, :integer
  attr :y, :integer
  attr :height, :integer
  attr :width, :integer
  attr :fill, :string

  defp rect(assigns) do
    ~H"""
            <rect width={@width} height={@height} x={@x } y={@y } fill={@fill} />
    """
  end

  defp circle(assigns) do
    ~H"""
        <circle cx={@x} cy={@y} r={@r} fill={@fill} />
    """
  end

  defp line_helper(assigns) do
    ~H"""
      <line x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}" stroke="black" stroke-width="2" />
      <line x1="#{x1}" y1="#{y1}" x2="#{x1 + 50 * Math.cos(angle)}" y2="#{y1 + 50 * Math.sin(angle)}" stroke="red" stroke-width="2" />
      <text x="#{x1}" y="#{y1}" dx="-20" dy="-10">P1</text>
      <text x="#{x2}" y="#{y2}" dx="20" dy="20">P2</text>
      <text x="#{x1 + 25 * Math.cos(angle)}" y="#{y1 + 25 * Math.sin(angle)}" dx="10" dy="-10">θ</text>
    """
  end

  defp snakec(assigns) do
    head = assigns[:snake].head
    body = assigns[:snake].body
    color = assigns[:snake].color

    ~H"""
    <%= for segment <- Enum.reverse(body) do %>
        <circle r={segment.r} cx={segment.x} cy={segment.y} fill={color} />
    <% end %>
      <circle r={head.r} cx={head.x} cy={head.y} fill="white" />
    """
  end

  defp foodc(assigns) do
    ~H"""
    <.circle r={10} x={@food.x} y={@food.y} fill="blue" />
    """
  end

  def input(assigns) do
    ~H"""
    <input id={@field.id} name={@field.name} value={@field.value} {@rest} />
    """
  end
end
