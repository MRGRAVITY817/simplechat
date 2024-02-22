defmodule SimplechatWeb.RoomChannel do
  use SimplechatWeb, :channel
  alias SimplechatWeb.Presence

  @impl true
  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    {:ok, msg} =
      Simplechat.Message.changeset(%Simplechat.Message{}, payload)
      |> Simplechat.Repo.insert()

    # Assign name to socket assigns and track presence
    socket
    |> assign(:person_name, msg.name)
    |> track_presence()
    |> broadcast("shout", Map.put_new(payload, :id, msg.id))

    {:noreply, socket}
  end

  defp track_presence(%{assigns: %{person_name: person_name}} = socket) do
    Presence.track(socket, person_name, %{
      online_at: inspect(System.system_time(:second))
    })

    socket
  end

  # Send existing messages to the client when they join
  @impl true
  def handle_info(:after_join, socket) do
    Simplechat.Message.get_messages()
    |> Enum.reverse()
    |> Enum.each(fn message ->
      push(socket, "shout", %{
        name: message.name,
        message: message.message,
        inserted_at: message.inserted_at
      })
    end)

    # Send currently active users
    push(socket, "presence_state", Presence.list("room:lobby"))

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
