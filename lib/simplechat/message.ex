defmodule Simplechat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "messages" do
    field :message, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message])
    |> validate_required([:name, :message])
  end

  @doc """
  Fetches all messages.
  """
  def get_messages(limit \\ 20) do
    from(
      m in Simplechat.Message,
      order_by: [desc: m.inserted_at],
      limit: ^limit
    )
    |> Simplechat.Repo.all()
  end
end
