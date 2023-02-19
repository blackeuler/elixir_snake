defmodule Snake.Game.Food do
  defstruct [:x, :y, :r]

  alias Snake.Game.Snake

  def new(w, h) do
    %__MODULE__{x: :random.uniform(w), y: :random.uniform(h), r: 10}
  end

  def from_snake(%Snake{body: body}) do
    Enum.map(body,fn r -> %__MODULE__{x: r.x, y: r.y, r: r.r} end)
  end

  def svg(%__MODULE__{} = m) do
    """
    <circle r="#{m.r}" x="#{m.x}" y="#{m.y}" fill="yellow" />
    """
  end
end
