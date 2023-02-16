defmodule Snake.Game.Snake do
  @derive {Jason.Encoder, only: [:head, :body, :color]}
  defstruct [:id, :head, :body, :angle, :speed, :color]

  def new({x, y}, id) do
    %__MODULE__{head: %{x: x, y: y}, id: id, color: "red", speed: 3, angle: 20.0}
  end

  def change_direction(%__MODULE__{} = snake, angle) do
    %{snake | angle: angle}
  end

  def move(%__MODULE__{angle: angle, speed: speed} = snake, delta_t \\ 0.1) do
    %{
      snake
      | head: %{
          x: snake.head.x + :math.cos(angle) * speed * delta_t,
          y: snake.head.y + :math.sin(angle) * speed * delta_t
        }
    }
  end

  def eat(%__MODULE__{head: oldhead} = snake) do
    snake = snake |> move
    %{snake | body: [oldhead | snake.body]}
  end

  def px_per_second(%__MODULE__{speed: s} = snake) do
    s
  end
end
