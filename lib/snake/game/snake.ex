defmodule Snake.Game.Snake do
  @derive {Jason.Encoder, only: [:head, :body, :color]}
  defstruct [:id, :head, :body, :angle, :speed, :color]

  def new({x, y}, id) do
    %__MODULE__{
      head: %{x: x, y: y, r: 10},
      id: id,
      body: [],
      color: "red",
      speed: 0.4,
      angle: 20.0
    }
  end

  def change_direction(%__MODULE__{} = snake, angle) do
    %{snake | angle: angle}
  end

  def heads_touching(%__MODULE__{head: h1, body: b1}, %__MODULE__{head: h2, body: b2}) do
    if distance(h1, h2) < h1.r + h2.r do
      :head
    else
      case Enum.find(b2, fn seg -> distance(h1, seg) < h1.r + seg.r end) do
        nil -> nil
        seg -> :body
      end
    end
  end

  defp distance(%{x: x1, y: y1}, %{x: x2, y: y2}) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end

  def move(%__MODULE__{angle: angle, head: head, body: body} = snake, delta_t \\ 1) do
    new_head = %{
      head
      | x: head.x + :math.cos(angle) * snake.speed * delta_t,
        y: head.y + :math.sin(angle) * snake.speed * delta_t
    }

    spacing = 5

    new_body =
      for {prev_seg, seg} <- Enum.zip([head | body], body) do
        dist = :math.sqrt(:math.pow(seg.x - prev_seg.x, 2) + :math.pow(seg.y - prev_seg.y, 2))
        ratio = spacing / dist

        new_x = prev_seg.x + ratio * (seg.x - prev_seg.x)
        new_y = prev_seg.y + ratio * (seg.y - prev_seg.y)

        %{seg | x: new_x, y: new_y}
      end

    %{snake | head: new_head, body: new_body}
  end

  def grow(%__MODULE__{head: oldhead} = snake) do
    snake = snake |> move
    %{snake | body: [oldhead | snake.body], speed: snake.speed + 0.01}
  end

  def die(%_MODULE__{head: head, body: body}) do
    Enum.map(body, fn f -> %Snake.Game.Food{x: f.x, y: f.y, r: f.r} end)
  end

  def px_per_second(%__MODULE__{speed: s} = snake) do
    s
  end
end
