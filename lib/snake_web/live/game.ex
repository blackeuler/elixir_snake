defmodule SnakeWeb.GameLive do
  use SnakeWeb, :live_view

  alias Snake.Game

  def render(assigns) do
    ~H"""
    Its time to play the game
    <%= if Game.current_player(@game_model) do %>
    <div  data-block="4"  >
      <svg phx-hook="move" id="game" viewBox={Game.to_svg_box(@game_model)} xmlns="http://www.w3.org/2000/svg">
            <!-- Simple rectangle -->
            <%= for snake <- @game_snakes do %>
                <.snakec snake={snake} />
            <% end %>
            <%= for food <- Game.all_food(@game_model) do %>
                <.foodc food={food} />
            <% end %>



       </svg>
    </div>
    <% end %>
    <button phx-click="update"> Update Me </button>
    """
  end

  def mount(_session, _params, socket) do
    {:ok, assign_game_model(socket) |> assign_snakes}
  end

  def assign_game_model(socket) do
    assign(socket, game_model: Game.start())
  end

  def assign_snakes(%{assigns: %{game_model: game_model}} = socket) do
    assign(socket, game_snakes: Game.all_snakes(game_model))
  end

  def handle_event("update", _params, socket) do
    Process.send_after(self(), :update, 10)
    {:noreply, assign(socket, game_model: Game.update(socket.assigns.game_model))}
  end

  def handle_event("angle_change", %{"x" => x, "y" => y}, socket) do
    {:noreply,
     assign(socket, game_model: Game.change_snake_angle(socket.assigns.game_model, 1, {x, y}))}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 10)

    {:noreply,
     assign(socket, game_model: Game.update(socket.assigns.game_model))
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

    ~H"""
    <%= for segment <- Enum.reverse(body) do %>
        <circle r={segment.r} cx={segment.x} cy={segment.y} fill="red" />
    <% end %>
      <circle r={head.r} cx={head.x} cy={head.y} fill="black" />
    """
  end

  defp foodc(assigns) do
    ~H"""
    <.circle r={10} x={@food.x} y={@food.y} fill="blue" />
    """
  end
end
