defmodule Snake.Game do
  alias Snake.Game.{Snake, Model}

  def start() do
    Model.new()
    |> Model.add_food()
    |> Model.add_snake(Snake.new({:random.uniform(330), 50}, 9))
    |> Model.add_snake(Snake.new({:random.uniform(330), 50}, 4))
    |> Model.add_snake(Snake.new({:random.uniform(330), 50}, 3))
    |> Model.add_snake(Snake.new({:random.uniform(330), 50}, 5))
    |> Model.add_snake(Model.snake_of_length(7))
    |> Model.generate_food(200)
  end

  def change_snake_angle(%Model{} = game, angle) do
    Model.update_snake_angle(game, angle)
  end

  def all_snakes(%Model{snakes: snakes}) do
    snakes
  end

  def all_food(%Model{food: food}) do
    food
  end

  def current_player(%Model{current_player: cp}) do
    cp
  end

  def update(%Model{} = game, delta_t) do
    Model.update(game, delta_t)
  end

  def to_svg_box(%Model{} = game) do
    Model.to_svg_box(game)
  end

  def background(%Model{width: width, height: height} = game) do
    "
            <rect width=#{width} height=#{height} x={@x } y={@y } fill={@fill} />
"
  end

  def draw_snake(%Model{} = game, snake_id) do
    Model.game_to_svg(game, snake_id)
  end
end
