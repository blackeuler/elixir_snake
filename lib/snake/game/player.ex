defmodule Snake.Game.Player do
  import Ecto.Changeset
  @types %{name: :string}
  defstruct [:name]

  def new(name \\ "") do
    %__MODULE__{name: name}
  end

  def changeset(player, attrs \\ %{}) do
    {player, @types}
    |> cast(attrs, Map.keys(@types))
  end
end
