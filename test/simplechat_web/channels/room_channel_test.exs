defmodule SimplechatWeb.RoomChannelTest do
  use SimplechatWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      SimplechatWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(SimplechatWeb.RoomChannel, "room:lobby")

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to room:lobby", %{socket: socket} do
    push(socket, "shout", %{"hello" => "all"})
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end

  test ":after_join sends existing messages to the client", %{socket: socket} do
    # Arrange
    payload = %{name: "Alice", message: "Hello"}
    Simplechat.Message.changeset(%Simplechat.Message{}, payload) |> Simplechat.Repo.insert()

    # Act
    {:ok, _, socket2} =
      SimplechatWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(SimplechatWeb.RoomChannel, "room:lobby")

    # Assert
    assert socket2.join_ref == socket.join_ref
  end
end
