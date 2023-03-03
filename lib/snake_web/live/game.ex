defmodule SnakeWeb.GameLive do
  use SnakeWeb, :live_view

  alias Snake.Game

  def render(assigns) do
    ~H"""
    <%= if @current_player do %>
    <h1> Current Player: <%= @current_player.user_name %> </h1>
    <div  data-block="4"  >
      <svg  phx-hook="move" id="game" viewBox={Game.to_svg_box(@game_model,@current_player)} xmlns="http://www.w3.org/2000/svg">
            <!-- Simple rectangle -->
            <rect width={@game_model.width} height={@game_model.height} x={0 } y={0 } fill="black" />
            <%= for snake <- @game_snakes do %>
                <.snakec snake={snake} />
            <% end %>
            <%= for food <- Game.all_food(@game_model) do %>
                <.foodc food={food} />
            <% end %>
       </svg>
    </div>
    <button phx-click="start"> Start Playing </button>
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
     |> assign_game_model()
     |> assign_snakes
     |> assign_player_changeset()}
  end

  def assign_game_model(socket) do
    assign(socket, game_model: Game.start())
  end

  def assign_snakes(%{assigns: %{game_model: game_model}} = socket) do
    assign(socket, game_snakes: Game.all_snakes(game_model))
  end

  def assign_player_changeset(socket) do
    assign(socket, player_changeset: Game.change_player())
    |> assign(current_player: nil)
  end

  def handle_event("start", _params, %{assigns: %{game_model: gm}} = socket) do
    Process.send_after(self(), :update, 10)
    {:noreply, assign(socket, game_model: Game.update(gm, 10))}
  end

  def handle_event(
        "angle_change",
        %{"x" => x, "y" => y},
        %{assigns: %{game_model: gm, current_player: cp}} = socket
      ) do
    {:noreply,
     assign(socket,
       game_model: Game.change_snake_angle(gm, {x, y}, cp)
     )}
  end

  def handle_event(
        "save",
        %{"player" => %{"name" => name}},
        %{assigns: %{game_model: gm}} = socket
      ) do
    snake = Game.new_snake_of_length(12, name)

    {:noreply,
     socket
     |> assign(:game_model, Game.add_snake(gm, snake))
     |> assign(:current_player, snake)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 15)

    {:noreply,
     assign(socket, game_model: Game.update(socket.assigns.game_model, 15))
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
