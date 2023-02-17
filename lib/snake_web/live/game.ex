defmodule SnakeWeb.GameLive do
  use SnakeWeb, :live_view

  alias Snake.Game

  def render(assigns) do
    ~H"""
    Its time to play the game
    <div  data-block="4"  >
      <svg phx-hook="move" id="game" viewBox="0 0 220 100" xmlns="http://www.w3.org/2000/svg">
            <!-- Simple rectangle -->
            <.rect width={10} height={10} x={0} y={1} fill="black" />
            <.rect width={10} height={10} x={0} y={0} fill="black" />


       </svg>

    </div>
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
    assign(socket, game_snakes: Game.all_snakes(game_model) |> Jason.encode!())
  end


  def handle_event("update", _params, socket) do
    {:noreply, assign(socket, game_model: Game.update(socket.assigns.game_model))}
  end

  def handle_event("angle_change", %{"x" => x, "y" => y}, socket) do
    IO.inspect({x,y}, label: "Mouse Position")

    angle = :math.atan2(x,y)
    {:noreply, assign(socket, game_model: Game.change_snake_angle(socket.assigns.game_model,1,angle) )}
  end
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 10)
    {:noreply,
     assign(socket, game_model: Game.update(socket.assigns.game_model))
     |> assign_snakes
    }
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
end
