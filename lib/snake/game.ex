defmodule Snake.Game do
  alias Snake.Game.{Snake, Model, Player}

  def new() do
    Model.new()
  end

  def start() do
    Model.new()
    |> Model.add_food()
    |> Model.add_snake(Snake.new({:rand.uniform(330), 50}))
    |> Model.add_snake(Snake.new({:rand.uniform(330), 50}))
    |> Model.add_snake(Snake.new({:rand.uniform(330), 50}))
    |> Model.add_snake(Snake.new({:rand.uniform(330), 50}))
    |> Model.generate_food(200)
  end

  def change_snake_angle(%Model{} = game, snake, angle) do
    Model.update_snake_angle(game, snake, angle)
  end

  def all_snakes(%Model{snakes: snakes}) do
    snakes
  end

  def add_snake(%Model{snakes: snakes} = m, snake) do
    Model.add_snake(m, snake)
  end

  def new_snake_of_length(length, user_name) do
    Model.snake_of_length(length, user_name)
  end

  def add_user_snake(%Model{} = m, user_name) do
    Model.add_snake(m, Model.snake_of_length(12, user_name))
  end

  def all_food(%Model{food: food}) do
    food
  end

  def change_player(attrs \\ %{}) do
    Player.new()
    |> Player.changeset(attrs)
  end

  def update(%Model{} = game, delta_t) do
    Model.update(game, delta_t)
  end

  def to_svg_box(%Model{} = game, snake, width, height) do
    Model.to_svg_box(game, snake, width, height)
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
