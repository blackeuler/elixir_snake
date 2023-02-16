defmodule SnakeWeb.GameLive do
  use SnakeWeb, :live_view

  alias Snake.Game

  def render(assigns) do
    ~H"""
    Its time to play the game
    <div data-snakes={@game_snakes} data-block="4" id="game" phx-hook="canvas">
    <canvas style="width: 100vw; height: 100vh;"  ></canvas>
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

  def handle_event("angle_change", %{"angle" => angle}, socket) do
    {:noreply, assign(socket, game_model: Game.change_snake_angle(socket.assigns.game_model,1,angle) )}
  end
  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 10)
    {:noreply,
     assign(socket, game_model: Game.update(socket.assigns.game_model))
     |> assign_snakes
    }
  end
end
