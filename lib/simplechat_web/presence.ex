defmodule SimplechatWeb.Presence do
  use Phoenix.Presence,
    otp_app: :simplechat,
    pubsub_server: Simplechat.PubSub
end
