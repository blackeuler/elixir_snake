defmodule Snake.Game.Model do
  defstruct [:current_player, :snakes, :food, width: 800, height: 800]

  alias Snake.Game.{Food, Snake}

  def new() do
    %__MODULE__{current_player: nil, snakes: [], food: []}
  end

  def add_snake(%__MODULE__{} = m, snake) do
    %{m | snakes: [snake | m.snakes], current_player: snake.id}
  end

  def add_food(%__MODULE__{width: width, height: height} = m) do
    %{m | food: [Food.new(width, height) | m.food]}
  end

  def generate_food(%__MODULE__{width: w, height: h, food: food} = m, num_food) do
    Enum.reduce(1..num_food, m, fn _, acc ->
      add_food(acc)
    end)
  end

  def snake_of_length(n) do
    Enum.reduce(1..n, Snake.new({90, 30}, 1), fn _, acc ->
      Snake.grow(acc)
    end)
  end

  def update(%__MODULE__{} = m, delta_t) do
    m
    |> handle_collisions()
    |> move_snakes(delta_t)
  end

  def move_snakes(%__MODULE__{snakes: snakes} = m, delta_t) do
    %{m | snakes: Enum.map(snakes, fn s -> Snake.move(s, delta_t) end)}
  end

  def handle_collisions(%__MODULE__{height: height, width: width,snakes: snakes, food: food, current_player: cp} = m) do
    {eaten_food, remaining_food} =
      Enum.split_with(food, fn f ->
        Enum.any?(snakes, fn s -> collides(s, f) end)
      end)

    new_snakes =
      Enum.map(snakes, fn snake ->
        if Enum.any?(eaten_food, fn f -> collides(snake, f) end) do
          Snake.grow(snake)
        else
          snake
        end
      end)

    {dead_snakes, alive_snakes} =
      Enum.split_with(new_snakes, fn s ->
        Enum.any?(new_snakes, fn other ->
          (s != other &&
             collides(s, other)) || s.head.x > width || s.head.y > height
        end)
      end)

    dead_snakes_food = List.flatten(Enum.map(dead_snakes, fn s -> Food.from_snake(s) end))
    new_food = remaining_food ++ dead_snakes_food

    %{m | snakes: alive_snakes, food: new_food}
  end

  defp collides(%Snake{head: head}, %Snake{head: other_head, body: other_body}) do
    distance(head, other_head) < head.r + other_head.r ||
      Enum.any?(other_body, fn seg -> distance(head, seg) < head.r + seg.r end)
  end

  defp collides(%Snake{head: head}, %Food{} = food) do
    distance(head, food) < head.r + food.r
  end

  def update_all_snakes(%__MODULE__{snakes: snakes} = m) do
    %{m | snakes: Enum.map(snakes, &Snake.move/1)}
  end

  def update_snake_angle(%__MODULE__{snakes: snakes, current_player: snake_id} = m, {x, y}) do
    %{
      m
      | snakes:
          Enum.map(snakes, fn snake ->
            if snake.id == snake_id do
              dx = x - snake.head.x
              dy = y - snake.head.y
              angle = :math.atan2(dy, dx)
              Snake.change_direction(snake, angle)
            else
              snake
            end
          end)
    }
  end

  def distance(p1, p2) do
    dx = p2.x - p1.x
    dy = p2.y - p1.y
    :math.sqrt(dx * dx + dy * dy)
  end

  def current_player(%__MODULE__{current_player: snake_id}) do
    snake_id
  end

  def to_svg_box(%__MODULE__{width: w, height: h, snakes: snakes, current_player: snake_id}) do
    snake = Enum.find(snakes, &(&1.id == snake_id))
    x_offset = snake.head.x - w / 2
    y_offset = snake.head.y - h / 2
    "#{x_offset} #{y_offset} #{w} #{h}"
  end
end
