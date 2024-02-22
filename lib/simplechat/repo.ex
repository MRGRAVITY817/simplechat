defmodule Simplechat.Repo do
  use Ecto.Repo,
    otp_app: :simplechat,
    adapter: Ecto.Adapters.Postgres
end
