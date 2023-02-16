defmodule Snake.Game.Model do
  defstruct [:snakes, :food, width: 800, height: 800]

  alias Snake.Game.Snake

  def new() do
    %__MODULE__{snakes: [], food: []}
  end

  def add_snake(%__MODULE__{} = m, snake) do
    %{m | snakes: [snake | m.snakes]}
  end

  def update(%__MODULE__{} = m) do
    update_all_snakes(m)
  end

  def update_all_snakes(%__MODULE__{snakes: snakes} = m) do
    %{m | snakes: Enum.map(snakes, &Snake.move/1)}
  end

  def update_snake_angle(%__MODULE__{snakes: snakes} = m, snake_id, angle) do
    %{
      m
      | snakes:
          Enum.map(snakes, fn snake ->
            if snake.id == snake_id do
              Snake.change_direction(snake, angle)
            else
              snake
            end
          end)
    }
  end
end
