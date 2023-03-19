defmodule Snake.Game.Server do
  use GenServer

  @tick_rate 10
  alias Snake.Game

  # Client

  def start_link(default) when is_list(default) do
    # Start the server with an initial game state
    GenServer.start_link(__MODULE__, default, name: GameServer)
  end

  def join(pid, user_name) do
    # Send a synchronous request to join the game
    GenServer.call(pid, {:join, user_name})
  end

  def change_snake_angle(pid, snake, angle) do
    # Send an asynchronous request to change the snake angle
    GenServer.cast(pid, {:change_snake_angle, snake, angle})
  end

  def get_game_state(pid) do
    # Send a synchronous request to get the current game state
    GenServer.call(pid, :get_game_state)
  end

  # Server (callbacks)
  @impl true
  def init(_) do
    schedule_update()
    {:ok, Game.start()}
  end

  @impl true
  def handle_info(:update, game_state) do
    # Update the game state using the Snake.Game module logic
    new_game_state = Game.update(game_state, @tick_rate)

    # Reschedule another update
    schedule_update()
    {:noreply, new_game_state}
  end

  @impl true
  def handle_cast({:update, delta_t}, game_state) do
    # Update the game state using the Snake.Game module logic
    new_game_state = Game.update(game_state, delta_t)

    {:noreply, new_game_state}
  end

  @impl true
  def handle_cast({:change_snake_angle, snake_id, angle}, game_state) do
    # Change the snake angle using the Snake.Game module logic
    new_game_state =
      Game.change_snake_angle(
        game_state,
        snake_id,
        angle
      )

    {:noreply, new_game_state}
  end

  @impl true
  def handle_call({:join, user_name}, _from, game_state) do
    # Update the game state using the Snake.Game module logic
    snake = Game.new_snake_of_length(12, user_name)
    IO.inspect(game_state)

    new_game_state = Game.add_snake(game_state, snake)

    # Reply withthe snake_id and the new game state
    {:reply, {snake, new_game_state}, new_game_state}
  end

  @impl true
  def handle_call(:get_game_state, _from, game_state) do
    # Reply withthe currentgamestate
    {:reply, game_state, game_state}
  end

  defp schedule_update() do
    # In 30 seconds
    Process.send_after(self(), :update, 10)
  end
end
