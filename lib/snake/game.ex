defmodule Snake.Game do
  alias Snake.Game.{Snake, Model}

  def start() do
    Model.new()
    |> Model.add_snake(Snake.new({3, 3},1))
  end

  def change_snake_angle(%Model{} = game, snake_id, angle) do
    Model.update_snake_angle(game,snake_id, angle)
  end

  def all_snakes(%Model{snakes: snakes}) do
    snakes
  end

  def update(%Model{} = game) do
    Model.update(game) |> IO.inspect()
  end
end
